package core

/*
   game_state_init initializes the game state.
   Exported for use by the main application.
   Returns a pointer to the initialized game state.
*/
@(export)
game_state_init :: proc() -> rawptr {
	app_state := state_init()
	return app_state
}

/*
   game_step processes one frame of the game.
   Exported for use by the main application.
   Returns false when the game should exit, true otherwise.
*/
@(export)
game_step :: proc(state: rawptr) -> bool {
	app_state := (^AppState)(state)
	return step(app_state)
}

/*
   game_state_free cleans up all resources and shuts down the game.
   Exported for use by the main application.
*/
@(export)
game_state_free :: proc(state: rawptr) {
	app_state := (^AppState)(state)
	state_free(app_state)
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
game_force_reload :: proc(state: rawptr) -> bool {
	app_state := (^AppState)(state)
	if app_state.force_reload {
		app_state.force_reload = false
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
game_force_reset :: proc(state: rawptr) -> bool {
	app_state := (^AppState)(state)
	if app_state.force_reset {
		app_state.force_reset = false
		return true
	}
	return false
}
