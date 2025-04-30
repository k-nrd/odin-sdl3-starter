# Project configuration
PROJECT_NAME := odin_sdl_starter
MAIN_DIR := src/main
LIB_DIR := src/game
BINDINGS_DIR := bindings
VENDOR_DIR := vendor
BUILD_DIR := build

# Third-party dependencies
SDL_DIR := $(VENDOR_DIR)/SDL
FAUDIO_DIR := $(VENDOR_DIR)/FAudio

ifeq ($(OS),Windows_NT)
    DLL_EXT := .dll
    BINARY_EXT := .exe
else
    DLL_EXT := .so
    BINARY_EXT := 
endif

# Output files
DEV_BINARY := $(BUILD_DIR)/$(PROJECT_NAME)_dev$(BINARY_EXT)
RELEASE_BINARY := $(BUILD_DIR)/$(PROJECT_NAME)$(BINARY_EXT)
DYLIB := $(BUILD_DIR)/lib$(PROJECT_NAME)$(DLL_EXT)

# Build flags
# BUILD_TYPE values correspond to Build_Type enum in config.odin:
# 0 = Development, 1 = Testing, 2 = Release
BASE_FLAGS := -collection:bindings=$(BINDINGS_DIR) -define:PROJECT_NAME=$(PROJECT_NAME)
DEV_FLAGS := -debug -o:minimal -show-timings -show-system-calls $(BASE_FLAGS)
DEV_FLAGS += -define:BUILD_TYPE=0
RELEASE_FLAGS := -o:speed -no-bounds-check $(BASE_FLAGS)
RELEASE_FLAGS += -define:BUILD_TYPE=2
DYLIB_FLAGS := -debug -build-mode:dll -no-entry-point -o:minimal $(BASE_FLAGS)

# Include directories
LINKER_FLAGS := -I$(SDL_DIR)/include -I$(FAUDIO_DIR)/include
# Library search paths
LINKER_FLAGS += -L$(SDL_DIR)/build -L$(FAUDIO_DIR)/build

.PHONY: all clean dev release preview update-deps build-lib copy-libs

# Default target builds release version
all: release

# Development build with hot-reload
dev: build-lib | $(BUILD_DIR) copy-libs
	@echo "Building development binary (with hot reload)..."
	odin build $(MAIN_DIR) $(DEV_FLAGS) \
		-out:$(DEV_BINARY) \
		-extra-linker-flags="$(LINKER_FLAGS)"
	
	@echo "Starting hot reload development environment..."
	@echo "Hot reload environment running. Edit $(LIB_DIR)/*.odin files to see changes."
	@# Run the binary once first, then start watchexec
	@$(DEV_BINARY); \
	watchexec -w $(LIB_DIR) --quiet --exts odin --on-busy-update=restart -- "make build-lib"

# Release build (statically linked)
release: | $(BUILD_DIR) copy-libs
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
	@echo "Building dynamic library for hot reload..."
	odin build $(LIB_DIR) $(DYLIB_FLAGS) \
		-out:$(DYLIB) \
		-extra-linker-flags="$(LINKER_FLAGS)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/*

# Copy libraries to build directory
copy-libs: | $(BUILD_DIR)
	@echo "Copying libraries to build directory..."
	@cp $(SDL_DIR)/build/libSDL3.so* $(BUILD_DIR)/
	@cp $(FAUDIO_DIR)/build/libFAudio.so* $(BUILD_DIR)/

# Update third-party dependencies
update-deps:
	@echo "Building CMake-based dependencies..."
	@mkdir -p $(SDL_DIR)/build && cd $(SDL_DIR) && cd build && cmake .. && make -j$$(nproc)
	@mkdir -p $(FAUDIO_DIR)/build && cd $(FAUDIO_DIR) && cd build && cmake .. && make -j$$(nproc)

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
