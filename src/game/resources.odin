package game

import "core:fmt"
import "core:strings"
import "vendor:sdl3"

/*
   load_media loads all media resources required by the game.
   Currently loads the hello-sdl3.bmp image.
   Returns true on success, false on failure.
*/
load_media :: proc() -> bool {
	filename := "assets/hello-sdl3.bmp"
	filename_cstr := strings.clone_to_cstring(filename)
	defer delete(filename_cstr)

	g_app_state.resources.hello_world = sdl3.LoadBMP(filename_cstr)
	if g_app_state.resources.hello_world == nil {
		fmt.eprintln("Failed to load image:", sdl3.GetError())
		return false
	}

	return true
}
