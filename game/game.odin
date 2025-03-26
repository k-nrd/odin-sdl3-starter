package game

import "../game_api"
import "core:fmt"
import "core:time"
import "vendor:sdl3"

// Game API - these functions will be exported and called from main

// Initialize the game systems, window, and resources
@(export)
init :: proc() -> bool {
	// Clear the game state
	g_state = {}

	if !sdl3.Init(sdl3.INIT_VIDEO | sdl3.INIT_AUDIO) {
		fmt.eprintln("Failed to initialize SDL3:", sdl3.GetError())
		return false
	}

	g_state.window_state.window = sdl3.CreateWindow(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, {})
	if g_state.window_state.window == nil {
		fmt.eprintln("Failed to create window:", sdl3.GetError())
		return false
	}

	g_state.window_state.surface = sdl3.GetWindowSurface(g_state.window_state.window)

	if !init_audio() {
		fmt.eprintln("Failed to initialize audio!")
		return false
	}

	if !load_media() {
		fmt.eprintln("Failed to load media!")
		return false
	}

	// Try to load sound as part of initialization
	_ = load_audio("assets/beep.wav")
	if g_state.audio_state.audioData != nil {
		g_state.loaded_sound = true
	}

	// Set running state to true
	g_state.running = true

	return true
}

// Main game loop - controlled by the game library
@(export)
run :: proc(callbacks: game_api.GameCallbacks) {
	for g_state.running {
		// Call before update callback
		if callbacks.on_before_update != nil {
			callbacks.on_before_update(callbacks.user_data)
		}

		// Update game state and handle events
		update()

		// Call after update callback
		if callbacks.on_after_update != nil {
			callbacks.on_after_update(callbacks.user_data)
		}

		// Call before render callback
		if callbacks.on_before_render != nil {
			callbacks.on_before_render(callbacks.user_data)
		}

		// Render the frame
		render()

		// Call after render callback
		if callbacks.on_after_render != nil {
			callbacks.on_after_render(callbacks.user_data)
		}

		// Frame limiting
		time.sleep(time.Millisecond * MAIN_DELAY)
	}
}

// Update game state, handle events
update :: proc() {
	event: sdl3.Event

	for sdl3.PollEvent(&event) {
		if event.type == .QUIT {
			g_state.running = false
		} else if event.type == .KEY_DOWN {
			key_event := cast(^sdl3.KeyboardEvent)&event
			if key_event.key == sdl3.K_ESCAPE {
				g_state.running = false
			}
			if key_event.key == sdl3.K_SPACE {
				if g_state.loaded_sound {
					play_sound()
				}
			}
		}
	}
}

// Render the current frame
render :: proc() {
	// Clear the screen
	sdl3.FillSurfaceRect(
		g_state.window_state.surface,
		sdl3.Rect{},
		sdl3.MapRGB(
			sdl3.GetPixelFormatDetails(g_state.window_state.surface.format),
			nil,
			0x44,
			0x44,
			0x44,
		),
	)

	// Apply the image
	if g_state.hello_world != nil {
		sdl3.BlitSurface(
			g_state.hello_world,
			sdl3.Rect{0, 0, WINDOW_WIDTH, WINDOW_HEIGHT},
			g_state.window_state.surface,
			sdl3.Rect{},
		)
	}

	// Update the surface
	sdl3.UpdateWindowSurface(g_state.window_state.window)
}

// Close game and free resources
@(export)
destroy :: proc() {
	if g_state.hello_world != nil {
		sdl3.free(g_state.hello_world)
		g_state.hello_world = nil
	}

	close_audio()

	if g_state.window_state.window != nil {
		sdl3.DestroyWindow(g_state.window_state.window)
		g_state.window_state.window = nil
	}

	sdl3.Quit()
}

// State management functions for hot-reloading
@(export)
get_state_ptr :: proc() -> rawptr {
	return state_get_ptr()
}

@(export)
get_state_size :: proc() -> int {
	return state_get_size()
}

@(export)
load_state :: proc(state_ptr: rawptr) {
	state_load(state_ptr)
}
