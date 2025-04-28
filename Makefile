# Project configuration
PROJECT_NAME = odin-sdl-starter
MAIN_DIR = src/main_release
LIB_DIR = src/game
BINDINGS_DIR = bindings
VENDOR_DIR = vendor
BUILD_DIR = build

# Third-party dependencies
SDL_DIR = $(VENDOR_DIR)/SDL2
IMGUI_DIR = $(VENDOR_DIR)/imgui

ifeq ($(OS),Windows_NT)
    DLL_EXT = .dll
    LIB_PREFIX = 
    BINARY_EXT = .exe
else
    DLL_EXT = .so
    LIB_PREFIX = lib
    BINARY_EXT = 
endif

# Output files
DEV_BINARY = $(BUILD_DIR)/$(PROJECT_NAME)_dev$(BINARY_EXT)
RELEASE_BINARY = $(BUILD_DIR)/$(PROJECT_NAME)$(BINARY_EXT)
DYLIB = $(BUILD_DIR)/$(LIB_PREFIX)$(PROJECT_NAME)_lib$(DLL_EXT)

# Build flags
BASE_FLAGS = -collection:bindings=$(BINDINGS_DIR) -I$(SDL_DIR)/include -I$(IMGUI_DIR)
DEV_FLAGS = -debug -define:HOT_RELOAD=true $(BASE_FLAGS)
RELEASE_FLAGS = -o:speed -no-bounds-check -define:HOT_RELOAD=false $(BASE_FLAGS)
DYLIB_FLAGS = -debug -build-mode:dll -no-entry-point $(BASE_FLAGS)
LINKER_FLAGS = -L$(SDL_DIR)/build -lSDL2 -lGL

.PHONY: all clean dev release preview update-deps build-lib

# Default target builds release version
all: release

# Development build with hot-reload
dev: | $(BUILD_DIR)
	build-lib

	@echo "Building development binary (with hot reload)..."
	odin build $(MAIN_DIR) $(DEV_FLAGS) \
		-out:$(DEV_BINARY) \
		-extra-linker-flags="$(LINKER_FLAGS)"
	
	@echo "Starting hot reload development environment..."
	@echo "Hot reload environment running. Edit $(LIB_DIR)/*.odin files to see changes."
	# watchexec monitors the game library directory for changes to Odin files.
	# When a change is detected:
	#  - --on-busy-update=restart: If changes happen during rebuilding, restart the process
	#  - --clear: Clear the terminal before each run for better visibility
	#  - The command rebuilds the library and immediately runs the game
	@watchexec -w $(LIB_DIR) --exts odin --on-busy-update=restart --clear -- "make build-lib && $(DEV_BINARY)"

# Release build (statically linked)
release: | $(BUILD_DIR)
	@echo "Building optimized release binary..."
	odin build $(MAIN_DIR) $(RELEASE_FLAGS) \
		-collection:lib=$(LIB_DIR) \
		-out:$(RELEASE_BINARY) \
		-extra-linker-flags="$(LINKER_FLAGS)"

# Run release build
preview: release
	@echo "Previewing release build..."
	@$(RELEASE_BINARY)

# Build of dynamic library for hot reload
build-lib: | $(BUILD_DIR)
	@echo "Building hot-reloadable library..."
	@odin build $(LIB_DIR) $(DYLIB_FLAGS) \
		-out:$(DYLIB) \
		-extra-linker-flags="$(LINKER_FLAGS)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/*

# Update third-party dependencies
update-deps:
	@echo "Updating all git submodules..."
	@git submodule update --init --recursive
	@echo "Building CMake-based dependencies..."
	@find $(VENDOR_DIR) -name "CMakeLists.txt" -exec dirname {} \; | while read dir; do \
		echo "Building $$dir..." && \
		cd $$dir && mkdir -p build && cd build && cmake .. && make -j$$(nproc); \
	done

# Update specific third-party dependency
update-deps-%: | $(BUILD_DIR)
	@echo "Updating third-party dependency: $*"
	@if [ -d "$(VENDOR_DIR)/$*" ]; then \
		git submodule update --init --recursive $(VENDOR_DIR)/$*; \
		if [ -f "$(VENDOR_DIR)/$*/CMakeLists.txt" ]; then \
			cd $(VENDOR_DIR)/$* && mkdir -p build && cd build && cmake .. && make -j$$(nproc); \
		fi; \
	else \
		echo "Error: Submodule $(VENDOR_DIR)/$* not found"; \
	fi

# Directory creation
$(BUILD_DIR):
	@mkdir -p $@