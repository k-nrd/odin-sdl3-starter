package game

import "core:fmt"
import "core:strings"
import "vendor:sdl3"

// Load media resources (images, textures, etc.)
load_media :: proc() -> bool {
	// Try to load Hello World image
	filename := "assets/hello-sdl3.bmp"
	filename_cstr := strings.clone_to_cstring(filename)
	defer delete(filename_cstr)

	g_state.hello_world = sdl3.LoadBMP(filename_cstr)
	if g_state.hello_world == nil {
		fmt.eprintln("Failed to load image:", sdl3.GetError())
		return false
	}

	return true
}
