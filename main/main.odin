package main

import "../game"
import "core:log"
import "core:os"
import "core:path/filepath"

/*
   main is the entry point for the application.
   It handles both development and release modes based on the build configuration.
*/
main :: proc() {
	// Get executable directory for consistent file paths
	exec_dir := filepath.dir(os.args[0])

	// Setup appropriate logger based on build type
	setup_logger(exec_dir)

	// Run the game with appropriate mode
	run_game(exec_dir)
}

/*
   setup_logger configures the logger based on build configuration.
   Priority: Console logging (if enabled) > File logging (if enabled)
*/
setup_logger :: proc(exec_dir: string) {
	// Prioritize console logging if enabled
	when CONSOLE_LOGGING {
		context.logger = log.create_console_logger()
	} else when FILE_LOGGING {
		// File logging only if console logging is disabled
		log_path := filepath.join({exec_dir, PROJECT_NAME + ".log"})
		log_file, err := os.open(log_path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC)

		if err == nil {
			context.logger = log.create_file_logger(log_file, log.Level.Info)
			defer os.close(log_file)
		} else {
			// Fallback to console if file fails
			context.logger = log.create_console_logger()
		}
	}
}

/*
   run_game runs the appropriate game loop based on build configuration.
   In development mode (with hot-reload): hot-reloading game loop.
   Otherwise: standard game loop.
*/
run_game :: proc(exec_dir: string) {
	when ENABLE_HOT_RELOAD {
		run_with_hot_reload(exec_dir)
	} else {
		// Standard game loop without hot-reloading
		state := game.game_state_init()
		defer game.game_state_free(state)

		// Main game loop
		for game.game_step(state) {}
	}
}

// Enable dedicated GPU on hybrid GPU systems
@(export)
NvOptimusEnablement: u32 = 1

@(export)
AmdPowerXpressRequestHighPerformance: i32 = 1
