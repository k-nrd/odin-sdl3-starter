package main

PROJECT_NAME :: #config(PROJECT_NAME, "odin_sdl_starter")

Build_Type :: enum {
	Development,
	Testing,
	Release,
}

BUILD_TYPE :: Build_Type(#config(BUILD_TYPE, 0))

ENABLE_HOT_RELOAD :: #config(ENABLE_HOT_RELOAD, BUILD_TYPE == .Development)

CONSOLE_LOGGING :: #config(CONSOLE_LOGGING, BUILD_TYPE != .Release)
FILE_LOGGING :: #config(FILE_LOGGING, true)
