Reverse Tower Defense - Vertical Slice Implementation Plan

 Overview

 Build a playable vertical slice of "Malicious Architecture" — a reverse tower defense where the player places road
  tiles (with pre-built enemy towers) and must sabotage tower effectiveness through spatial placement and rotation.

 Project Structure

 res://
 ├── project.godot
 ├── autoload/
 │   └── game_events.gd              # Global signal bus
 ├── scenes/
 │   ├── main.tscn                    # Entry point, manages game states
 │   ├── game_board/
 │   │   └── game_board.tscn          # The playing field + camera
 │   ├── tiles/
 │   │   └── road_tile.tscn           # Placeable road tile (road + tower slots)
 │   ├── towers/
 │   │   └── archer_tower.tscn        # First tower type
 │   ├── demons/
 │   │   └── demon.tscn               # Basic demon unit
 │   ├── projectiles/
 │   │   └── arrow.tscn               # Arrow projectile
 │   └── ui/
 │       ├── hud.tscn                 # Mana, wave, health display
 │       ├── draft_panel.tscn         # 3 tile choices
 │       └── tile_preview.tscn        # Ghost preview during placement
 ├── scripts/
 │   ├── core/
 │   │   ├── game_manager.gd          # Phase state machine, round progression
 │   │   ├── wave_manager.gd          # Demon spawning per wave
 │   │   └── mana_manager.gd          # Mana tracking
 │   ├── grid/
 │   │   ├── grid_system.gd           # Abstract base (swap to hex later)
 │   │   └── square_grid.gd           # Square grid implementation
 │   ├── tiles/
 │   │   ├── road_tile.gd             # Tile behavior (rotation, placement)
 │   │   ├── tile_data.gd             # Resource: road edges, tower slots
 │   │   └── tile_placer.gd           # Handles placement validation + preview
 │   ├── towers/
 │   │   ├── tower_base.gd            # Targeting, firing, range
 │   │   └── archer_tower.gd          # Archer specifics
 │   ├── demons/
 │   │   ├── demon.gd                 # Health, speed, mana carrying
 │   │   └── path_follower.gd         # Follows road path points
 │   ├── draft/
 │   │   ├── draft_manager.gd         # Generates 3 tile options, handles selection
 │   │   └── tile_generator.gd        # Random tile creation from pool
 │   └── ui/
 │       ├── hud.gd
 │       ├── draft_panel.gd
 │       └── tile_preview.gd
 └── resources/
     ├── tiles/
     │   ├── straight_road.tres        # N-S connection
     │   ├── curve_road.tres           # N-E connection
     │   └── t_junction_road.tres      # N-E-S connection
     └── towers/
         └── archer_data.tres          # Range, damage, fire rate

 Main Scene Tree

 Main (Node2D) [game_manager.gd]
 ├── GameBoard (Node2D)
 │   ├── TileContainer (YSort/Node2D) — holds placed RoadTile instances
 │   ├── DemonContainer (YSort/Node2D) — holds Demon instances
 │   └── ProjectileContainer (Node2D)
 ├── TilePlacer (Node2D) [tile_placer.gd] — ghost preview + click-to-place
 ├── Camera2D — isometric view, centered on board
 ├── WaveManager (Node) [wave_manager.gd]
 ├── ManaManager (Node) [mana_manager.gd]
 ├── DraftManager (Node) [draft_manager.gd]
 └── UI (CanvasLayer)
     ├── HUD [hud.gd]
     └── DraftPanel [draft_panel.gd]

 Grid Abstraction (Hex-Ready)

 grid_system.gd — abstract base defining the interface:
 - cell_to_world(coords: Vector2i) -> Vector2 — grid to isometric screen position
 - world_to_cell(world_pos: Vector2) -> Vector2i — screen click to grid coords
 - get_neighbors(coords: Vector2i) -> Array[Vector2i]
 - get_edge_count() -> int — 4 for square, 6 for hex
 - rotate_edges(edges: Array[bool], steps: int) -> Array[bool]
 - get_opposite_edge(edge: int) -> int
 - get_neighbor_on_edge(coords: Vector2i, edge: int) -> Vector2i

 square_grid.gd — implements with isometric projection:
 - Edges indexed 0-3: North, East, South, West
 - Isometric conversion: screen.x = (gx - gy) * tile_half_w, screen.y = (gx + gy) * tile_half_h
 - Standard tile size: 128x64px (2:1 isometric ratio)

 Swapping to hex later = create hex_grid.gd implementing the same interface with 6 edges and hex coordinate math.
 No other system needs to change.

 Tile Data Model

 tile_data.gd (extends Resource):
 - road_edges: Array[bool] — which edges have road connections (size = grid.edge_count)
 - tower_slots: Array[TowerSlot] — each has: local_offset (Vector2i), tower_type (enum), facing_edge (int)
 - tile_name: String

 Road types for square grid:
 - Straight: [N, _, S, ] or [, E, _, W]
 - Curve: [N, E, _, ], [, E, S, _], etc.
 - T-Junction: [N, E, S, _], etc.

 Rotation = shift the road_edges and tower_slots arrays by N positions.

 Signal Flow

 GameEvents autoload (signal bus):
   - phase_changed(phase: GamePhase)
   - tile_drafted(tile_data: TileData)
   - tile_placed(coords: Vector2i, tile_data: TileData, rotation: int)
   - tile_placement_cancelled()
   - wave_started(wave_number: int)
   - wave_ended()
   - demon_spawned(demon: Node2D)
   - demon_reached_goal(demon: Node2D)
   - demon_killed(demon: Node2D)
   - mana_changed(new_amount: int)
   - demon_lord_damaged(new_health: int)
   - game_over(victory: bool)

 Game Phase State Machine

 DRAFT → PLACE → WAVE → RESOLVE → DRAFT (next round)

 - DRAFT: DraftManager generates 3 tiles, DraftPanel displays them. Player clicks one.
 - PLACE: TilePlacer shows ghost preview. Player rotates (R key) and clicks valid cell. Path recalculates.
 - WAVE: WaveManager spawns demons. Towers fire. Demons walk path. Ends when all demons reach goal or die.
 - RESOLVE: Count surviving demons, add mana, check win/lose, increment round.

 Implementation Phases (Ordered)

 Phase 1: Foundation (files: 6)

 1. Create folder structure
 2. autoload/game_events.gd — signal bus with all signals
 3. scripts/grid/grid_system.gd — abstract base class
 4. scripts/grid/square_grid.gd — isometric square grid
 5. scenes/main.tscn + scripts/core/game_manager.gd — phase state machine (DRAFT/PLACE/WAVE/RESOLVE)
 6. scenes/game_board/game_board.tscn — Camera2D with isometric setup
 7. Register game_events.gd as autoload in project.godot

 Verification: Run project, see empty isometric grid with camera. Click cells, print grid coords to console.

 Phase 2: Tile System (files: 5)

 1. scripts/tiles/tile_data.gd — Resource class for tile definitions
 2. resources/tiles/*.tres — 3 tile data resources (straight, curve, T-junction) with tower slot definitions
 3. scenes/tiles/road_tile.tscn + scripts/tiles/road_tile.gd — visual tile with procedural isometric drawing (roads
  as lines, tower slots as markers)
 4. scripts/tiles/tile_placer.gd — placement logic: valid cell highlighting, rotation, snap-to-grid, connection
 validation
 5. Demon Lord starting tile placed at origin automatically

 Verification: Run project, see Demon Lord tile. Can manually place tiles adjacent to it, rotate with R, see road
 connections validate.

 Phase 3: Drafting (files: 4)

 1. scripts/draft/tile_generator.gd — generates random TileData from weighted pool
 2. scripts/draft/draft_manager.gd — creates 3 options per round, emits selection
 3. scenes/ui/draft_panel.tscn + scripts/ui/draft_panel.gd — 3 clickable tile previews
 4. Wire DRAFT phase: show panel → player picks → enter PLACE phase

 Verification: Run project. See 3 tile options. Click one, enter placement mode. Place it. New round starts with 3
 new options.

 Phase 4: Path & Demons (files: 4)

 1. scripts/demons/path_follower.gd — follows array of world-space waypoints along road
 2. scenes/demons/demon.tscn + scripts/demons/demon.gd — health, speed, mana crystal, procedural isometric sprite
 3. scripts/core/wave_manager.gd — spawns N demons at path start with staggered timing
 4. Path calculation: BFS/DFS from newest tile to Demon Lord tile, generate waypoints from cell centers

 Verification: Place a few tiles manually, trigger wave. See demons walk the path from start to Demon Lord.

 Phase 5: Towers (files: 4)

 1. scripts/towers/tower_base.gd — range detection (Area2D), target selection (nearest), fire rate timer, rotation
 toward target
 2. scripts/towers/archer_tower.gd — fires arrows, damage on hit
 3. scenes/towers/archer_tower.tscn — Area2D for range, procedural sprite
 4. scenes/projectiles/arrow.tscn — simple projectile that moves toward target and deals damage
 5. Towers auto-instantiate when tiles are placed based on tower_slots in TileData

 Verification: Place tiles with tower slots. Trigger wave. See towers fire at demons, demons take damage and can
 die.

 Phase 6: Game Loop & HUD (files: 4)

 1. scripts/core/mana_manager.gd — tracks mana, awards on demon delivery
 2. scenes/ui/hud.tscn + scripts/ui/hud.gd — displays mana, wave number, Demon Lord health
 3. Wire RESOLVE phase: tally results, check win (mana target) / lose (Demon Lord health ≤ 0)
 4. Game over screen (simple label + restart button)

 Verification: Full loop playable — draft tile, place it, watch wave, collect mana, repeat. Win by reaching mana
 target or lose when Demon Lord dies.

 Placeholder Art Strategy

 All visuals drawn procedurally via _draw() overrides (no external art assets needed):
 - Tiles: Isometric diamond outline (white), road paths drawn as thick colored lines between connected edges
 - Towers: Small colored circles on tile (red = archer) with range ring shown on hover
 - Demons: Green circles moving along path, health bar above
 - Demon Lord: Large purple diamond at origin tile
 - Arrows: Small white lines moving toward target
 - UI: Godot's built-in theme, simple panels and labels

 Key Design Notes

 - Path grows outward: Demon Lord sits at origin. Each round adds a tile at the far end of the path (the "start"
 from demons' perspective). Demons spawn at the newest tile and walk inward.
 - Valid placement: New tile must be adjacent to the current path start tile, and the connecting edges must both
 have road connections.
 - Tower sabotage: Towers have a facing direction. If a tower faces a tile edge with no road, it's effectively
 useless. This is the core puzzle.
 - Y-sorting: Use Godot's Y-sort to handle isometric depth ordering for demons and towers.
