# Game Project Organization

This document outlines the recommended project structure for our game, designed to scale from a simple prototype to a complex game while maintaining clean organization.

## Structure Overview

```
/game               # Main game package
  /core             # Core game systems
  /entities         # Game entities
  /common           # Shared systems and utilities
  /scenes           # Scene management
  /events           # Event and trigger systems
  /resources        # Resource management
/main               # Main application
```

## Package Details

### Core (/game/core)

Contains the foundational game systems that coordinate everything else.

```
/core
  api.odin            # Public API for main application
  game.odin           # Game loop and coordination
  state.odin          # Core game state
  system_manager.odin # System activation/scheduling
```

### Entities (/game/entities)

Each game entity gets its own sub-package, allowing for progressive complexity scaling.

```
/entities
  entities.odin       # Entity registration and common functionality
  
  /player             # Player package
    player.odin       # Start with a single file
    # Can expand to multiple files as needed:
    # data.odin, movement.odin, render.odin, etc.
  
  /crab               # Crab enemy package
    crab.odin         # Start with a single file
  
  # Add more entity packages as needed
```

### Common (/game/common)

Shared systems used by multiple entities or scenes.

```
/common
  /physics
    physics.odin      # Physics system
  
  /rendering
    rendering.odin    # Core rendering system
    sprites.odin      # Sprite management
    particles.odin    # Particle system
  
  /audio
    audio.odin        # Audio system
  
  /utils
    math.odin         # Math utilities
    spatial.odin      # Spatial data structures
```

### Scenes (/game/scenes)

Game scenes and level management.

```
/scenes
  scenes.odin         # Scene management and transitions
  
  /world              # Main game world
    world.odin        # World scene implementation
  
  /minigames          # Minigames as separate scenes
    fishing.odin      # Fishing minigame
```

### Events (/game/events)

Event handling and trigger system.

```
/events
  events.odin         # Event system
  triggers.odin       # Trigger system (location/condition based events)
```

### Resources (/game/resources)

Asset loading and management.

```
/resources
  resources.odin      # Resource management
  loaders.odin        # Asset loaders
```

## Progressive Complexity Approach

This structure follows a "progressive complexity" approach:

1. **Start Simple**: Begin with single files in each package
2. **Expand as Needed**: Split into multiple files when a domain becomes complex
3. **Stable API**: Other code imports packages, not specific files, so internal reorganization doesn't break imports

## System Activation

The structure supports dynamic system activation:

- Each scene defines which systems are active
- Triggers can activate/deactivate systems based on game events
- All without conditional checks in hot code paths

## Data-Oriented Design

This structure is compatible with data-oriented design:

- Entity packages can use SoA (Structure of Arrays) layout internally
- System functions operate on arrays of data
- Hot/cold data separation can be implemented within each package

## Implementation Example

### Simple Version

```odin
// entities/crab/crab.odin
package crab

Crab :: struct {
    position: Vector2,
    velocity: Vector2,
    state: enum { IDLE, HUNTING, FLEEING },
}

MAX_CRABS :: 100
crabs: [MAX_CRABS]Crab
count: int

update :: proc(dt: f32) {
    // Update all crabs
}

render :: proc(alpha: f32) {
    // Render all crabs
}

register_systems :: proc(sys_manager: ^SystemManager) {
    sys_manager.register(.CRAB_SYSTEM, update, render)
}
```

### Expanded Version

When the entity becomes more complex, expand into multiple files while keeping the same package API:

```odin
// entities/crab/crab.odin (main file)
package crab

// Public API stays the same
register_systems :: proc(sys_manager: ^SystemManager) {
    sys_manager.register(.CRAB_SYSTEM, update, render)
}

// entities/crab/data.odin
package crab

Crab :: struct {
    position: Vector2,
    velocity: Vector2,
    state: CrabState,
}

CrabState :: enum {
    IDLE, HUNTING, FLEEING,
}

MAX_CRABS :: 100
crabs: [MAX_CRABS]Crab
count: int

// entities/crab/update.odin
package crab

update :: proc(dt: f32) {
    // Update logic in its own file
}

// entities/crab/render.odin
package crab

render :: proc(alpha: f32) {
    // Render logic in its own file
}
```

Importers still just use `import "../entities/crab"` regardless of internal organization.
