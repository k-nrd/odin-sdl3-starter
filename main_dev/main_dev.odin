package main_dev

import "core:c/libc"
import "core:dynlib"
import "core:fmt"
import "core:log"
import "core:os"
import "core:path/filepath"
import "core:strings"

import "../game_api"

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

// Store game library functions in a struct
GameLib :: struct {
	_lib:           dynlib.Library,
	init:           game_api.Init_Proc,
	run:            game_api.Run_Proc,
	destroy:        game_api.Destroy_Proc,
	get_state_ptr:  game_api.Get_State_Ptr_Proc,
	get_state_size: game_api.Get_State_Size_Proc,
	load_state:     game_api.Load_State_Proc,
}

// Hot reload context for callbacks
HotReloadContext :: struct {
	lib:      ^GameLib,
	mod_time: os.File_Time,
	exec_dir: string, // Path to executable directory
}

// Global version counter for library files
api_version := 0

// Callback for before update - checks for hot-reload
on_before_update :: proc(user_data: rawptr) {
	hr_ctx := cast(^HotReloadContext)user_data
	if hr_ctx == nil do return

	// Check for hot-reload
	new_mod_time, ok := read_lib_modification_time(hr_ctx.exec_dir)
	if !ok do return // Continue if we can't read the modification time

	// Only reload if modification time changed
	if new_mod_time == hr_ctx.mod_time do return

	log.info("Detected library change, hot-reloading...")

	// Load the new library
	new_lib, new_lib_ok := load_lib(hr_ctx.exec_dir)
	if !new_lib_ok {
		log.error("Failed to load updated library")
		return // Continue with old library
	}

	// Get state sizes
	old_size := hr_ctx.lib.get_state_size()
	new_size := new_lib.get_state_size()

	if old_size != new_size {
		// State size changed - reinitialize
		log.info("State size changed, reinitializing game")
		new_lib.init()
	} else {
		// Preserve state from old library
		log.info("Preserving game state during hot-reload")
		new_lib.load_state(hr_ctx.lib.get_state_ptr())
	}

	// Clean up old library
	unload_lib(hr_ctx.lib)

	// Switch to new library in context
	hr_ctx.lib^ = new_lib
	hr_ctx.mod_time = new_mod_time
}

main :: proc() {
	context.logger = log.create_console_logger()

	log.info("Starting development build with hot-reloading")

	// Get executable directory for consistent library loading
	exec_dir := filepath.dir(os.args[0])
	log.infof("Executable directory: %s", exec_dir)

	// Initial check for game library file
	mod_time, mod_time_ok := read_lib_modification_time(exec_dir)
	if !mod_time_ok {
		log.error("Failed to read library modification time, exiting")
		return
	}

	// Load initial game library
	game, game_ok := load_lib(exec_dir)
	if !game_ok {
		log.error("Failed to load game library, exiting")
		return
	}

	// Initialize the game
	if !game.init() {
		log.error("Failed to initialize game, exiting")
		return
	}
	defer game.destroy()
	defer unload_lib(&game)

	// Create hot reload context
	hot_reload_ctx := HotReloadContext {
		lib      = &game,
		mod_time = mod_time,
		exec_dir = exec_dir,
	}

	callbacks := game_api.GameCallbacks {
		on_before_update = on_before_update,
		user_data        = &hot_reload_ctx,
	}

	// Run the game
	game.run(callbacks)
}

// Read the last modification time of the library file
read_lib_modification_time :: proc(exec_dir: string) -> (os.File_Time, bool) {
	lib_path := filepath.join({exec_dir, BASE_LIB_FILENAME})
	mod_time, err := os.last_write_time_by_name(lib_path)
	if err != os.ERROR_NONE {
		log.errorf("Failed getting last write time of %s, error code: %d", lib_path, err)
		return mod_time, false
	}
	return mod_time, true
}

// Copy the DLL/SO to a versioned name to avoid file locks
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

// Load the game library with all symbols
load_lib :: proc(exec_dir: string) -> (lib: GameLib, ok: bool) {
	// Get path to base library
	base_lib_path := filepath.join({exec_dir, BASE_LIB_FILENAME})

	// Create versioned library name
	versioned_filename := fmt.tprintf("game_%d%s", api_version, DLL_EXT)
	versioned_lib_path := filepath.join({exec_dir, versioned_filename})

	// Copy base library to versioned name to avoid file locks
	if !copy_dll(exec_dir, base_lib_path, versioned_lib_path) {
		return
	}

	// Load library symbols into struct
	_, ok = dynlib.initialize_symbols(&lib, versioned_lib_path, handle_field_name = "_lib")
	if !ok {
		log.errorf("Failed initializing symbols: %s", dynlib.last_error())
		return
	}

	// Increment version for next load
	api_version += 1
	return
}

// Unload the game library
unload_lib :: proc(lib: ^GameLib) {
	if lib != nil && !dynlib.unload_library(lib._lib) {
		log.warnf("Failed unloading lib: %s", dynlib.last_error())
	}
}

// Enable dedicated GPU on hybrid GPU systems
@(export)
NvOptimusEnablement: u32 = 1

@(export)
AmdPowerXpressRequestHighPerformance: i32 = 1
