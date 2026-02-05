extends Node

## global signals
# Phase mgmt
enum GamePhase {
	DRAFT,
	PLACE,
	WAVE,
	RESOLVE
}
signal phase_changed(phase: GamePhase)

# Tile Lifecycle
signal tile_drafted(tile_data)
signal tile_placed(coords, tile_data, rotation)
signal tile_placement_cancelled()

# Wave/combat
signal wave_started(wave_number: int)
signal wave_ended()
signal demon_spawned(demon)
signal demon_reached_goal(demon)
signal demon_killed(demon)

# Economy/health
signal mana_changed(new_amount: int)
signal demon_lord_damaged(new_health)
signal game_over(victory)
