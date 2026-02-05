# Malicious Architecture - Reverse Tower Defense

## Current Progress
**Phase 1: Foundation** — Complete
**Phase 2: Tile System** — In Progress

## Phase 2 Status
Completed:
- `tile_data.gd` — Resource class for tile definitions
- `tower_slot.gd` — Resource for tower slot data (local_offset, tower_type, facing_edge)
- `tower_data.gd` — Resource for tower stats (damage, fire_rate, range)
- `resources/tiles/*.tres` — 3 tile resources (straight, curve, T-junction)
- `resources/towers/archer_data.tres` — Archer tower data
- `road_tile.tscn` + `road_tile.gd` — Visual tile with `_draw()` for diamond/roads/markers

In Progress:
- `tile_placer.gd` — Discussed all methods, `_draw()` not yet implemented

Remaining Phase 2:
- Implement `tile_placer.gd` `_draw()` function (ghost preview with green/red validity)
- Add Demon Lord starting tile at origin on game start

## Phase 2 Key Code Details

### tile_placer.gd structure
- `grid: SquareGrid` — for coordinate conversion
- `current_tile: TileData` — tile being placed
- `rotation_steps: int` — 0-3 rotation
- `is_placing: bool` — active during PLACE phase
- `hover_cell: Vector2i` — cell under mouse
- `placed_tiles: Dictionary` — tracks placed tiles (Vector2i -> TileData)
- `tile_container: Node2D` — ref to GameBoard/TileContainer

### Validation logic
Cell is valid if: empty, adjacent to existing tile, and connecting edges both have roads.

### Demon Lord starting tile
Needs to be placed at `Vector2i(0, 0)` at game start. Can be a special TileData with roads on all 4 edges, or handled specially. Must be in `placed_tiles` dictionary.

## Remaining Phases

### Phase 3: Drafting (4 files)
- `tile_generator.gd` — random TileData from weighted pool
- `draft_manager.gd` — creates 3 options per round
- `draft_panel.tscn` + `draft_panel.gd` — 3 clickable tile previews

### Phase 4: Path & Demons (4 files)
- `path_follower.gd` — follows waypoints along road
- `demon.tscn` + `demon.gd` — health, speed, mana, procedural sprite
- `wave_manager.gd` — spawns N demons at path start
- Path calculation: BFS from newest tile to Demon Lord

### Phase 5: Towers (4 files)
- `tower_base.gd` — range detection, targeting, fire rate
- `archer_tower.gd` — fires arrows, damage on hit
- `archer_tower.tscn` — Area2D for range, procedural sprite
- `arrow.tscn` — projectile that moves and deals damage
- Towers auto-instantiate from tower_slots when tiles placed

### Phase 6: Game Loop & HUD (4 files)
- `mana_manager.gd` — tracks mana, awards on demon delivery
- `hud.tscn` + `hud.gd` — displays mana, wave, Demon Lord health
- Wire RESOLVE phase: tally results, check win/lose
- Game over screen

## Key Design Reminders
- Path grows outward from Demon Lord (origin). Demons spawn at newest tile edge.
- Tower sabotage: towers face a direction. If facing edge has no road, tower is useless.
- Y-sorting on DemonContainer for isometric depth.
