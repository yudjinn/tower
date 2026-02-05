extends Node2D

var current_phase: GameEvents.GamePhase = GameEvents.GamePhase.DRAFT
var current_round: int = 1

func _ready() -> void:
	GameEvents.tile_placed.connect(_on_tile_placed)
	GameEvents.wave_ended.connect(_on_wave_ended)
	change_phase(GameEvents.GamePhase.DRAFT)
	

func change_phase(new_phase: GameEvents.GamePhase) -> void:
	current_phase = new_phase
	GameEvents.phase_changed.emit(new_phase)

func _on_tile_placed(_coords, _tile_data, _rotation):
	change_phase(GameEvents.GamePhase.WAVE)
	
func _on_wave_ended():
	change_phase(GameEvents.GamePhase.RESOLVE)
	resolve_round()
	
func resolve_round():
	current_round += 1
	change_phase(GameEvents.GamePhase.DRAFT)
	

	
