package game

/*
   game_state_init initializes the game state.
   Exported for use by the main application.
   Returns a pointer to the initialized game state.
*/
@(export)
game_state_init :: proc() {
	state_init()
}

/*
   game_state_load loads the game state from the provided pointer.
   If the pointer is nil, it will initialize a new game state.
   Exported for use by the main application.
*/
@(export)
game_state_load :: proc(state_ptr: rawptr) {
	state_load(state_ptr)
}

/*
   game_step processes one frame of the game.
   Exported for use by the main application.
   Returns false when the game should exit, true otherwise.
*/
@(export)
game_step :: proc() -> bool {
	return step()
}

/*
   game_state_free cleans up all resources and shuts down the game.
   Exported for use by the main application.
*/
@(export)
game_state_free :: proc() {
	state_free()
}

/*
   game_state_get_ptr returns a pointer to the current game state.
   Used for hot-reloading to preserve state across reloads.
   Exported for use by the main application.
*/
@(export)
game_state_get_ptr :: proc() -> rawptr {
	return state_get_ptr()
}

/*
   game_state_get_size returns the size of the AppState struct.
   Used for hot-reloading to check if the state structure has changed.
   Exported for use by the main application.
*/
@(export)
game_state_get_size :: proc() -> int {
	return state_get_size()
}

/*
   game_force_reload checks if a reload has been requested (via F6 key).
   Exported for use by the main application.
   Returns true if a reload was requested, false otherwise.
*/
@(export)
game_force_reload :: proc() -> bool {
	if g_app_state.force_reload {
		g_app_state.force_reload = false
		return true
	}
	return false
}

/*
   game_force_reset checks if a state reset has been requested (via F5 key).
   Exported for use by the main application.
   Returns true if a reset was requested, false otherwise.
*/
@(export)
game_force_reset :: proc() -> bool {
	if g_app_state.force_reset {
		g_app_state.force_reset = false
		return true
	}
	return false
}
