package game_api

// GameCallbacks structure for external hooks
GameCallbacks :: struct {
	on_before_update: proc(user_data: rawptr),
	on_after_update:  proc(user_data: rawptr),
	on_before_render: proc(user_data: rawptr),
	on_after_render:  proc(user_data: rawptr),
	user_data:        rawptr,
}

// Game API Function Types
Init_Proc :: #type proc() -> bool
Run_Proc :: #type proc(callbacks: GameCallbacks)
Destroy_Proc :: #type proc()
Get_State_Ptr_Proc :: #type proc() -> rawptr
Get_State_Size_Proc :: #type proc() -> int
Load_State_Proc :: #type proc(state: rawptr)
