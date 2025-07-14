package core

import "../common/mixer"
import "../common/renderer"
import "core:time"
import "vendor:sdl3"

// Constants for timing
FIXED_UPDATE_FPS :: 60
FIXED_TIME_STEP :: 1.0 / f64(FIXED_UPDATE_FPS) // In seconds
MAX_FRAME_TIME :: 0.25 // Maximum frame time to prevent spiral of death

/*
   step processes one frame of the game, including:
   - Event handling (input, quit, etc.)
   - Fixed timestep updates (game logic, physics)
   - Variable timestep rendering
   Returns false when the game should exit, true otherwise.
*/
step :: proc(app_state: ^AppState) -> bool {
	// Get current time
	current_time := sdl3.GetTicks()

	// Initialize last_time if this is the first frame
	if app_state.last_time == 0 {
		app_state.last_time = current_time
		return true
	}

	// Calculate delta time (in seconds)
	frame_time := f64(current_time - app_state.last_time) / 1000.0
	app_state.last_time = current_time

	// Cap maximum frame time to prevent spiral of death
	if frame_time > MAX_FRAME_TIME {
		frame_time = MAX_FRAME_TIME
	}

	// Add to accumulator
	app_state.accumulator += frame_time
	app_state.delta_time = frame_time // Store for interpolation if needed

	// Process events (outside fixed update loop for responsiveness)
	event: sdl3.Event
	for sdl3.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			return false
		case .KEY_DOWN:
			key_event := cast(^sdl3.KeyboardEvent)&event
			if key_event.key == sdl3.K_ESCAPE {
				return false
			}
			if key_event.key == sdl3.K_SPACE {
				// Play a sound effect using the sound stored in the audio context
				mixer.sound_play_by_name(app_state.mixer_ctx, "game_sound")
			}
			if key_event.key == sdl3.K_F5 {
				app_state.force_reset = true
			}
			if key_event.key == sdl3.K_F6 {
				app_state.force_reload = true
			}
		}
	}

	// Fixed update loop - may run 0, 1, or multiple times per frame
	for app_state.accumulator >= FIXED_TIME_STEP {
		game_update(app_state, FIXED_TIME_STEP)
		app_state.accumulator -= FIXED_TIME_STEP
	}

	// Calculate interpolation alpha for smooth rendering
	alpha := app_state.accumulator / FIXED_TIME_STEP

	// Render with interpolation
	game_render(app_state, alpha)

	return true
}

/*
   game_update updates game state with fixed time step
   All game logic, physics, AI, etc. should go here
*/
game_update :: proc(app_state: ^AppState, dt: f64) {
	// Put all your game state updates here
	// For example, updating player position, AI, physics, etc.
	// Use the fixed dt for all calculations

	// Example (uncomment and modify as needed):
	// app_state.game.player_x += int(velocity_x * dt)
	// app_state.game.player_y += int(velocity_y * dt)
}

/*
   game_render handles all rendering with interpolation for smooth visuals
   This runs as fast as the hardware allows (but is throttled by adaptive VSync)
*/
game_render :: proc(app_state: ^AppState, alpha: f64) {
	// Use the rendering context to begin a new frame
	cmd_buf, render_pass := renderer.renderer_begin_frame(app_state.renderer_ctx)
	if cmd_buf == nil || render_pass == nil {
		return
	}

	// This is where you'd render all your game entities
	// Use alpha to interpolate between previous and current positions if needed
	// Example (uncomment and modify as needed):
	// render_pos_x := lerp(prev_pos_x, current_pos_x, alpha)
	// render_pos_y := lerp(prev_pos_y, current_pos_y, alpha)
	// draw_entity(render_pos_x, render_pos_y)

	// Use the rendering context to end the frame
	renderer.renderer_end_frame(app_state.renderer_ctx, cmd_buf, render_pass)
}
