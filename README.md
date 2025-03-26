# Odin SDL3 Starter

## Prerequisites

- [Odin compiler](https://odin-lang.org/)
- [Go Task](https://taskfile.dev/) for building and running

## Libraries

This project depends on a few libraries being added as git subtrees:

- SDL3 in `vendor/SDL`
- FAudio in `vendor/FAudio`
- odin-faudio in `bindings/faudio`

Commands to add the subtrees are included in the `taskfile.yml`

## Building and Running

```bash
# List all available tasks
task --list

# Build dev version with hot reload (watches for changes in the game/ package)
task

# Build release version (statically links game package)
task build

# Add SDL3 as a subtree (only needed once)
task add-sdl3

# Update the SDL3 subtree to the latest release
task update-sdl3

# Clean build artifacts
task clean
```

## License

This project is open source and available under the [MIT License](LICENSE).
