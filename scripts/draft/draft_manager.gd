class_name DraftManager
extends Node

var tile_generator: TileGenerator
var current_options: Array[GameTileData] = []

func _ready() -> void:
	tile_generator = TileGenerator.new()
	add_child(tile_generator)
	GameEvents.phase_changed.connect(_on_phase_changed)
	GameEvents.tile_placed.connect(_on_tile_placed)

func _on_phase_changed(phase: int):
	if phase == GameEvents.GamePhase.DRAFT:
		if current_options.is_empty():
			current_options = tile_generator.generate_options(3)
		GameEvents.draft_options_ready.emit(current_options)


func select_tile(index: int):
	if index >= 0 and index < current_options.size():
		var selected = current_options[index]
		GameEvents.tile_drafted.emit(selected)


func _on_tile_placed(_coords, _tile_data, _rotation):
	current_options.clear()
