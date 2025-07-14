package core

import "../common/mixer"
import "../common/renderer"
import "core:log"
import "vendor:sdl3"

WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
WINDOW_TITLE :: "SDL3 Demo with FAudio"

GameState :: struct {
	player_x: int,
	player_y: int,
}

/*
   AppState contains all the game-specific state that can be preserved
   across hot reloads. It also includes flags for controlling reloading.
*/
AppState :: struct {
	mixer_ctx:    ^mixer.MixerContext, // Audio context
	renderer_ctx: ^renderer.RendererContext, // Renderer context (renamed)
	game:         ^GameState,
	force_reset:  bool,
	force_reload: bool,

	// Timing variables for fixed update, variable render loop
	last_time:    u64, // Last frame timestamp
	accumulator:  f64, // Time accumulator for fixed updates
	delta_time:   f64, // Time between frames
}

/*
   state_get_size returns the size of the AppState struct.
   Used for hot-reloading to check if the state structure has changed.
*/
state_get_size :: proc() -> int {
	return size_of(AppState)
}

/*
   state_init initializes the game state.
   This is called once at startup and not during hot reloads.
   Returns a pointer to the initialized AppState.
*/
state_init :: proc() -> ^AppState {
	app_state := new(AppState)
	app_state^ = AppState{}
	log.debug("Game state initialized")

	app_state.game = new(GameState)
	app_state.game^ = GameState{}
	log.debug("Game state initialized")

	app_state.last_time = 0
	app_state.accumulator = 0
	app_state.delta_time = 0

	// Initialize audio context (will initialize SDL audio subsystem)
	app_state.mixer_ctx = mixer.mixer_create()
	assert(app_state.mixer_ctx != nil, "Failed to initialize audio context")

	// Initialize renderer context (will initialize SDL video subsystem)
	app_state.renderer_ctx = renderer.renderer_create(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT)
	assert(app_state.renderer_ctx != nil, "Failed to initialize renderer context")

	// Load hello world image in the renderer context
	assert(
		renderer.surface_load(app_state.renderer_ctx, "hello_world", "game/assets/hello-sdl3.bmp"),
		"Failed to load hello world surface!",
	)

	// Load main game sound into the audio context
	assert(
		mixer.sound_load(app_state.mixer_ctx, "game_sound", "game/assets/beep.wav"),
		"Failed to load game sound",
	)

	return app_state
}

/*
   state_free cleans up all resources and shuts down the game.
   This is called when the game exits or before a hot reload.
*/
state_free :: proc(app_state: ^AppState) {
	// Clean up renderer context
	renderer.renderer_destroy(app_state.renderer_ctx)

	// Clean up audio context
	mixer.mixer_destroy(app_state.mixer_ctx)

	free(app_state.game)
	free(app_state)

	sdl3.Quit()
}
