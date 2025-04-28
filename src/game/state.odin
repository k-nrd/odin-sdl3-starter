package game

import "bindings:faudio"
import "core:log"
import "vendor:sdl3"

WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
WINDOW_TITLE :: "SDL3 Demo with FAudio"
MAIN_DELAY :: 16 // ~60 fps (in milliseconds)

/*
   WindowState contains all the window and system resources that need to be
   initialized once and persist across hot reloads.
*/
WindowState :: struct {
	window:  ^sdl3.Window,
	surface: ^sdl3.Surface,
	gpu:     ^sdl3.GPUDevice,
}

/*
   AudioState contains all the audio resources and state.
*/
AudioState :: struct {
	audio:          ^faudio.FAudio,
	masteringVoice: ^faudio.FAudioMasteringVoice,
	sourceVoice:    ^faudio.FAudioSourceVoice,
	audioData:      []byte,
	wfx:            faudio.FAudioWaveFormatEx,
	buffer:         faudio.FAudioBuffer,
}

GameState :: struct {
	player_x: int,
	player_y: int,
}

ResourcesState :: struct {
	hello_world: ^sdl3.Surface,
}

/*
   AppState contains all the game-specific state that can be preserved
   across hot reloads. It also includes flags for controlling reloading.
*/
AppState :: struct {
	window:       ^WindowState,
	audio:        ^AudioState,
	resources:    ^ResourcesState,
	game:         ^GameState,
	force_reset:  bool,
	force_reload: bool,
}

// Global states
g_app_state: ^AppState

/*
   state_get_ptr returns a pointer to the current game state.
   Used for hot-reloading to preserve state across reloads.
*/
state_get_ptr :: proc() -> rawptr {
	return g_app_state
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
*/
state_init :: proc() {
	g_app_state = new(AppState)
	g_app_state^ = AppState{}
	log.debug("Game state initialized")

	g_app_state.window = new(WindowState)
	g_app_state.window^ = WindowState{}
	log.debug("Window state initialized")

	g_app_state.audio = new(AudioState)
	g_app_state.audio^ = AudioState{}
	log.debug("Audio state initialized")

	g_app_state.resources = new(ResourcesState)
	g_app_state.resources^ = ResourcesState{}
	log.debug("Resources state initialized")

	g_app_state.game = new(GameState)
	g_app_state.game^ = GameState{}
	log.debug("Game state initialized")

	assert(sdl3.Init(sdl3.INIT_VIDEO | sdl3.INIT_AUDIO), "Failed to initialize SDL3")

	g_app_state.window.window = sdl3.CreateWindow(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, {})
	assert(g_app_state.window.window != nil, "Failed to create window")

	g_app_state.window.surface = sdl3.GetWindowSurface(g_app_state.window.window)
	assert(g_app_state.window.surface != nil, "Failed to get window surface")

	g_app_state.window.gpu = sdl3.CreateGPUDevice({.SPIRV}, true, nil)
	assert(g_app_state.window.gpu != nil, "Failed to create GPU device")

	assert(
		sdl3.ClaimWindowForGPUDevice(g_app_state.window.gpu, g_app_state.window.window),
		"Failed to claim window for GPU device",
	)

	assert(init_audio(), "Failed to initialize audio")

	assert(load_media(), "Failed to load media!")

	_ = load_audio("assets/beep.wav")
	assert(g_app_state.audio.audioData != nil, "Failed to load sound")
}

/*
   state_load initializes or loads the game state.
   If state_ptr is provided, it loads the state from that pointer.
*/
state_load :: proc(state_ptr: rawptr) {
	if state_ptr == nil do return
	g_app_state = (^AppState)(state_ptr)
	log.debug("Loaded new state")
}

/*
   state_free cleans up all resources and shuts down the game.
   This is called when the game exits or before a hot reload.
*/
state_free :: proc() {
	if g_app_state.resources.hello_world != nil {
		sdl3.free(g_app_state.resources.hello_world)
	}

	close_audio()

	if g_app_state.window.window != nil {
		sdl3.DestroyWindow(g_app_state.window.window)
	}

	free(g_app_state.window)
	free(g_app_state.audio)
	free(g_app_state)

	sdl3.Quit()
}
