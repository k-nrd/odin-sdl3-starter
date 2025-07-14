package main

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
BASE_LIB_FILENAME :: "lib" + PROJECT_NAME
LIB_FILENAME :: BASE_LIB_FILENAME + DLL_EXT

// GameLib contains all function pointers loaded from the game library
GameLib :: struct {
	_lib:           dynlib.Library,
	state_init:     proc() -> rawptr,
	state_free:     proc(state: rawptr),
	state_get_size: proc() -> int,
	step:           proc(state: rawptr) -> bool,
	force_reload:   proc(state: rawptr) -> bool,
	force_reset:    proc(state: rawptr) -> bool,
}

// Global version counter for library files
api_version := 0

// Hot-reload game loop
run_with_hot_reload :: proc(exec_dir: string) {
	mod_time, mod_time_ok := read_lib_modification_time(exec_dir)
	if !mod_time_ok {
		log.error("Failed to read library modification time, exiting")
		return
	}

	game_lib, game_lib_ok := load_game_lib(exec_dir)
	if !game_lib_ok {
		log.error("Failed to load game library, exiting")
		return
	}
	defer unload_game_lib(&game_lib)

	state := game_lib.state_init()
	defer game_lib.state_free(state)

	current_mod_time := mod_time
	for current_mod_time = mod_time; game_lib.step(state); {
		mod_time = read_lib_modification_time(exec_dir) or_continue

		reset := game_lib.force_reset(state)
		reload := game_lib.force_reload(state) || mod_time != current_mod_time
		if !(reload || reset) do continue

		log.debugf("Reloading game library: last=%v new=%v", current_mod_time, mod_time)
		new_game_lib := load_game_lib(exec_dir) or_continue
		old_size := game_lib.state_get_size()
		new_size := new_game_lib.state_get_size()

		if old_size != new_size || reset {
			log.debug("State size changed or reset forced, reinitializing state")
			game_lib.state_free(state)
			state = new_game_lib.state_init()
		} else {
			log.debug("Preserving game state during hot-reload")
		}

		unload_game_lib(&game_lib)
		game_lib = new_game_lib
		current_mod_time = mod_time
	}

	log.debug("Game exited normally")
}

// Support functions for hot-reloading
read_lib_modification_time :: proc(exec_dir: string) -> (os.File_Time, bool) {
	lib_path := filepath.join({exec_dir, LIB_FILENAME})
	mod_time, err := os.last_write_time_by_name(lib_path)
	if err != os.ERROR_NONE {
		log.errorf("Failed getting last write time of %s, error code: %d", lib_path, err)
		return mod_time, false
	}
	return mod_time, true
}

copy_game_lib :: proc(exec_dir: string, from_path, to_path: string) -> bool {
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

load_game_lib :: proc(exec_dir: string) -> (game_lib: GameLib, ok: bool) {
	base_lib_path := filepath.join({exec_dir, LIB_FILENAME})

	versioned_filename := fmt.tprintf(BASE_LIB_FILENAME + "_%d%s", api_version, DLL_EXT)
	versioned_lib_path := filepath.join({exec_dir, versioned_filename})

	if !copy_game_lib(exec_dir, base_lib_path, versioned_lib_path) {
		return
	}

	_, ok = dynlib.initialize_symbols(
		&game_lib,
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

unload_game_lib :: proc(game_lib: ^GameLib) {
	if game_lib != nil && game_lib._lib != nil {
		if !dynlib.unload_library(game_lib._lib) {
			log.warnf("Failed unloading game library: %s", dynlib.last_error())
		}
	}
}
