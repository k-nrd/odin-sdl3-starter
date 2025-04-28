package game

import "core:time"
import "vendor:sdl3"

/*
   step processes one frame of the game, including:
   - Event handling (input, quit, etc.)
   - Rendering the frame
   - Frame limiting
   Returns false when the game should exit, true otherwise.
*/
step :: proc() -> bool {
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
				play_sound()
			}
			if key_event.key == sdl3.K_F5 {
				g_app_state.force_reset = true
			}
			if key_event.key == sdl3.K_F6 {
				g_app_state.force_reload = true
			}
		}
	}

	/*
	   Rendering process:
	   1. Acquire command buffer
	   2. Acquire swapchain texture
	   3. Begin render pass with clear color
	   4. Draw content (currently empty)
	   5. End render pass and submit command buffer
	*/
	cmd_buf := sdl3.AcquireGPUCommandBuffer(g_app_state.window.gpu)
	swapchain_tex: ^sdl3.GPUTexture
	assert(
		sdl3.WaitAndAcquireGPUSwapchainTexture(
			cmd_buf,
			g_app_state.window.window,
			&swapchain_tex,
			nil,
			nil,
		),
		"Failed to acquire swapchain texture",
	)
	color_target := sdl3.GPUColorTargetInfo {
		texture     = swapchain_tex,
		load_op     = .CLEAR,
		store_op    = .STORE,
		clear_color = {0.4, 0.6, 0.9, 1.0},
	}
	render_pass := sdl3.BeginGPURenderPass(cmd_buf, &color_target, 1, nil)
	sdl3.EndGPURenderPass(render_pass)
	assert(sdl3.SubmitGPUCommandBuffer(cmd_buf), "Failed to submit GPU command buffer")

	time.sleep(time.Millisecond * MAIN_DELAY)

	return true
}
