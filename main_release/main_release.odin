package main_release

import "../game"
import "../game_api"
import "core:log"
import "core:os"
import "core:path/filepath"

main :: proc() {
	// Get executable directory for consistent logging
	exec_dir := filepath.dir(os.args[0])

	// Get path to log file
	log_path := filepath.join({exec_dir, "game.log"})

	// Create a file for logging
	log_file, err := os.open(log_path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
	if err != nil {
		// Fall back to console logger if file can't be opened
		context.logger = log.create_console_logger()
	} else {
		// Set up file logger
		context.logger = log.create_file_logger(log_file, log.Level.Info)
		defer os.close(log_file)
	}

	log.info("Starting release build")

	// Initialize the game
	if !game.init() {
		log.error("Failed to initialize game, exiting")
		return
	}
	defer game.destroy()

	// Run game
	game.run(game_api.GameCallbacks{})

	log.info("Game finished, exiting")
}

// Enable dedicated GPU on hybrid GPU systems
@(export)
NvOptimusEnablement: u32 = 1

@(export)
AmdPowerXpressRequestHighPerformance: i32 = 1
