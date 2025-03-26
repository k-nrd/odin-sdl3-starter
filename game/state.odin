package game

import "bindings:faudio"
import "vendor:sdl3"

WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
WINDOW_TITLE :: "SDL3 Demo with FAudio"
MAIN_DELAY :: 16 // ~60 fps (in milliseconds)

WindowState :: struct {
	window:  ^sdl3.Window,
	surface: ^sdl3.Surface,
}

AudioState :: struct {
	audio:          ^faudio.FAudio,
	masteringVoice: ^faudio.FAudioMasteringVoice,
	sourceVoice:    ^faudio.FAudioSourceVoice,
	audioData:      []byte,
	wfx:            faudio.FAudioWaveFormatEx,
	buffer:         faudio.FAudioBuffer,
}

GameState :: struct {
	window_state: WindowState,
	audio_state:  AudioState,
	hello_world:  ^sdl3.Surface,
	loaded_sound: bool,
	running:      bool,
}

// Global game state
g_state: GameState

// For hot-reloading
state_get_ptr :: proc() -> rawptr {
	return &g_state
}

state_get_size :: proc() -> int {
	return size_of(GameState)
}

state_load :: proc(state_ptr: rawptr) {
	if state_ptr != nil {
		g_state = (cast(^GameState)state_ptr)^
	}
}
