package main_dev

import "core:c/libc"
import "core:dynlib"
import "core:fmt"
import "core:log"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Determine dynamic library extension based on OS
when ODIN_OS == .Windows {
	DLL_EXT :: ".dll"
} else when ODIN_OS == .Darwin {
	DLL_EXT :: ".dylib"
} else {
	DLL_EXT :: ".so"
}

// Base library filename
BASE_LIB_FILENAME :: "game" + DLL_EXT

/*
   GameLib contains all the function pointers loaded from the game library.
   These functions are dynamically loaded and can be hot-reloaded during development.
*/
GameLib :: struct {
	_lib:           dynlib.Library,
	state_init:     proc(),
	state_load:     proc(state_ptr: rawptr),
	state_free:     proc(),
	state_get_ptr:  proc() -> rawptr,
	state_get_size: proc() -> int,
	step:           proc() -> bool,
	force_reload:   proc() -> bool,
	force_reset:    proc() -> bool,
}

// Global version counter for library files
api_version := 0

/*
   main is the entry point for the development build with hot-reloading support.
   It initializes the game, manages the game loop, and handles hot-reloading when
   the game library changes.
*/
main :: proc() {
	context.logger = log.create_console_logger()
	log.debug("Starting development build with hot-reloading")

	exec_dir := filepath.dir(os.args[0])
	log.debugf("Executable directory: %s", exec_dir)

	mod_time, mod_time_ok := read_lib_modification_time(exec_dir)
	if !mod_time_ok {
		log.error("Failed to read library modification time, exiting")
		return
	}

	lib, lib_ok := load_lib(exec_dir)
	if !lib_ok {
		log.error("Failed to load game library, exiting")
		return
	}
	defer unload_lib(&lib)

	lib.state_init()
	defer lib.state_free()

	/*
		Hot-reloading process:
		1. Load the new library
		2. Check if state size has changed
		3. Initialize the new library with either the old state or a fresh state
		4. Clean up the old library
		5. Update the library reference
	*/
	current_mod_time := mod_time
	for current_mod_time = mod_time; lib.step(); {
		mod_time = read_lib_modification_time(exec_dir) or_continue

		reset := lib.force_reset()
		reload := lib.force_reload() || mod_time != current_mod_time
		if !(reload || reset) do continue

		log.debugf("Reloading lib: last=%v new=%v", current_mod_time, mod_time)
		new_lib := load_lib(exec_dir) or_continue
		old_size := lib.state_get_size()
		new_size := new_lib.state_get_size()

		if old_size != new_size || reset {
			log.debug("State size changed or reset forced, reinitializing state")
			lib.state_free()
			new_lib.state_init()
		} else {
			log.debug("Preserving game state during hot-reload")
			new_lib.state_load(lib.state_get_ptr())
		}

		unload_lib(&lib)
		lib = new_lib
		current_mod_time = mod_time
	}

	log.debug("Game exited normally")
}

/*
   read_lib_modification_time retrieves the last modification time of the game library file.
   Returns the modification time and a boolean indicating success.
*/
read_lib_modification_time :: proc(exec_dir: string) -> (os.File_Time, bool) {
	lib_path := filepath.join({exec_dir, BASE_LIB_FILENAME})
	mod_time, err := os.last_write_time_by_name(lib_path)
	if err != os.ERROR_NONE {
		log.errorf("Failed getting last write time of %s, error code: %d", lib_path, err)
		return mod_time, false
	}
	return mod_time, true
}

/*
   copy_dll copies the game library to a versioned filename to avoid file locks.
   This allows the original file to be replaced while the versioned copy is in use.
*/
copy_dll :: proc(exec_dir: string, from_path, to_path: string) -> bool {
	cmd: string
	when ODIN_OS == .Windows {
		cmd = fmt.tprintf("copy \"%s\" \"%s\"", from_path, to_path)
	} else {
		cmd = fmt.tprintf("cp \"%s\" \"%s\"", from_path, to_path)
	}

	cmd_cstr := strings.clone_to_cstring(cmd)
	defer delete(cmd_cstr)

	exit := libc.system(cmd_cstr)
	if exit != 0 {
		log.errorf("Failed to copy %s to %s", from_path, to_path)
		return false
	}
	return true
}

/*
   load_lib loads the game library and initializes all function pointers.
   It creates a versioned copy of the library to avoid file locks, then
   dynamically loads all symbols into the GameLib struct.
   Returns the initialized GameLib and a boolean indicating success.
*/
load_lib :: proc(exec_dir: string) -> (lib: GameLib, ok: bool) {
	base_lib_path := filepath.join({exec_dir, BASE_LIB_FILENAME})

	versioned_filename := fmt.tprintf("game_%d%s", api_version, DLL_EXT)
	versioned_lib_path := filepath.join({exec_dir, versioned_filename})

	if !copy_dll(exec_dir, base_lib_path, versioned_lib_path) {
		return
	}

	_, ok = dynlib.initialize_symbols(
		&lib,
		versioned_lib_path,
		symbol_prefix = "game_",
		handle_field_name = "_lib",
	)
	if !ok {
		log.errorf("Failed initializing symbols: %s", dynlib.last_error())
		return
	}

	api_version += 1
	return
}

/*
   Safely unloads the game library.
*/
unload_lib :: proc(lib: ^GameLib) {
	if lib != nil && lib._lib != nil {
		if !dynlib.unload_library(lib._lib) {
			log.warnf("Failed unloading lib: %s", dynlib.last_error())
		}
	}
}

// Enable dedicated GPU on hybrid GPU systems
@(export)
NvOptimusEnablement: u32 = 1

@(export)
AmdPowerXpressRequestHighPerformance: i32 = 1
