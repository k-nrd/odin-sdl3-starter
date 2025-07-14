package renderer

import "core:log"
import "core:strings"
import "vendor:sdl3"

// Renderer context for managing rendering state
RendererContext :: struct {
	window:      ^sdl3.Window,
	gpu:         ^sdl3.GPUDevice,
	initialized: bool,
	surfaces:    map[string]^sdl3.Surface, // Store surfaces by name
}

// Create and initialize a renderer context
renderer_create :: proc(
	window_title: string,
	window_width: int,
	window_height: int,
) -> ^RendererContext {
	ctx := new(RendererContext)
	ctx.surfaces = make(map[string]^sdl3.Surface)

	// Always initialize SDL video subsystem
	if !sdl3.InitSubSystem(sdl3.INIT_VIDEO) {
		log.errorf("Failed to initialize SDL3 video: %s", sdl3.GetError())
		free(ctx)
		return nil
	}

	// Convert string to cstring for SDL
	title_cstr := strings.clone_to_cstring(window_title)
	defer delete(title_cstr)

	// Create window with i32 dimensions
	ctx.window = sdl3.CreateWindow(title_cstr, i32(window_width), i32(window_height), {})
	if ctx.window == nil {
		log.errorf("Failed to create window: %s", sdl3.GetError())
		free(ctx)
		return nil
	}

	// Create GPU device
	ctx.gpu = sdl3.CreateGPUDevice({.SPIRV}, true, nil)
	if ctx.gpu == nil {
		log.errorf("Failed to create GPU device: %s", sdl3.GetError())
		sdl3.DestroyWindow(ctx.window)
		free(ctx)
		return nil
	}

	// Claim window for GPU device
	if !sdl3.ClaimWindowForGPUDevice(ctx.gpu, ctx.window) {
		log.errorf("Failed to claim window for GPU device: %s", sdl3.GetError())
		sdl3.DestroyGPUDevice(ctx.gpu)
		sdl3.DestroyWindow(ctx.window)
		free(ctx)
		return nil
	}

	// Set swapchain parameters
	if !sdl3.SetGPUSwapchainParameters(ctx.gpu, ctx.window, .SDR, .IMMEDIATE) {
		log.errorf("Failed to set swapchain parameters: %s", sdl3.GetError())
		sdl3.DestroyGPUDevice(ctx.gpu)
		sdl3.DestroyWindow(ctx.window)
		free(ctx)
		return nil
	}

	ctx.initialized = true
	return ctx
}

// Destroy the renderer context and free all resources
renderer_destroy :: proc(ctx: ^RendererContext) {
	if ctx == nil do return

	// Free all loaded surfaces
	for _, surface in ctx.surfaces {
		if surface != nil {
			sdl3.free(surface)
		}
	}
	delete(ctx.surfaces)

	// Clean up GPU and window
	if ctx.gpu != nil {
		sdl3.DestroyGPUDevice(ctx.gpu)
	}

	if ctx.window != nil {
		sdl3.DestroyWindow(ctx.window)
	}

	ctx.initialized = false
	ctx.window = nil
	ctx.gpu = nil

	free(ctx)
}

// Load a surface from a file and store it in the context by name
surface_load :: proc(ctx: ^RendererContext, name: string, filename: string) -> bool {
	if ctx == nil || !ctx.initialized do return false

	// Convert string to cstring for SDL
	filename_cstr := strings.clone_to_cstring(filename)
	defer delete(filename_cstr)

	// Load the BMP image
	surface := sdl3.LoadBMP(filename_cstr)
	if surface == nil {
		log.errorf("Failed to load surface: %s", sdl3.GetError())
		return false
	}

	// Store the surface in the context
	ctx.surfaces[name] = surface
	return true
}

// Get a surface by name
surface_get :: proc(ctx: ^RendererContext, name: string) -> (^sdl3.Surface, bool) {
	if ctx == nil || !ctx.initialized do return nil, false

	surface, ok := ctx.surfaces[name]
	return surface, ok
}

// Free a single surface from the context
surface_free :: proc(ctx: ^RendererContext, name: string) -> bool {
	if ctx == nil || !ctx.initialized do return false

	surface, ok := ctx.surfaces[name]
	if !ok do return false

	if surface != nil {
		sdl3.free(surface)
	}
	delete_key(&ctx.surfaces, name)
	return true
}

// Begin a new frame
renderer_begin_frame :: proc(
	ctx: ^RendererContext,
) -> (
	cmd_buf: ^sdl3.GPUCommandBuffer,
	render_pass: ^sdl3.GPURenderPass,
) {
	if ctx == nil || !ctx.initialized {
		return nil, nil
	}

	cmd_buf = sdl3.AcquireGPUCommandBuffer(ctx.gpu)
	swapchain_tex: ^sdl3.GPUTexture

	if !sdl3.WaitAndAcquireGPUSwapchainTexture(cmd_buf, ctx.window, &swapchain_tex, nil, nil) {
		return nil, nil
	}

	color_target := sdl3.GPUColorTargetInfo {
		texture     = swapchain_tex,
		load_op     = .CLEAR,
		store_op    = .STORE,
		clear_color = {0.4, 0.6, 0.9, 1.0},
	}

	render_pass = sdl3.BeginGPURenderPass(cmd_buf, &color_target, 1, nil)
	return cmd_buf, render_pass
}

// End the current frame
renderer_end_frame :: proc(
	ctx: ^RendererContext,
	cmd_buf: ^sdl3.GPUCommandBuffer,
	render_pass: ^sdl3.GPURenderPass,
) -> bool {
	if ctx == nil || !ctx.initialized || cmd_buf == nil || render_pass == nil {
		return false
	}

	sdl3.EndGPURenderPass(render_pass)
	return sdl3.SubmitGPUCommandBuffer(cmd_buf)
}

// Draw a rectangle (placeholder for more sophisticated drawing)
renderer_draw_rect :: proc(
	ctx: ^RendererContext,
	render_pass: ^sdl3.GPURenderPass,
	x, y, width, height: int,
	color: [4]f32,
) {
	if ctx == nil || !ctx.initialized do return

	// This is a placeholder - in a real implementation, you would create geometry, shaders, etc.
	// For now, it's just a stub that would be implemented later
}
