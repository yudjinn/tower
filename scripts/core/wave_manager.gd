extends Node


var path_finder: PathFinder
var demon_scene = preload("res://scenes/demons/demon.tscn")
var spawn_count: int = 0
var demons_slain: int = 0
var wave_active: bool = false
var wave_count: int = 0

func _ready() -> void:
	path_finder = get_node("../TilePlacer").path_finder
	GameEvents.phase_changed.connect(_on_phase_changed)
	GameEvents.demon_killed.connect(_on_demon_removed)
	GameEvents.demon_reached_goal.connect(_on_demon_removed)

func _on_phase_changed(phase) -> void:
	if phase == GameEvents.GamePhase.WAVE:
		start_wave()

func start_wave() -> void:
	wave_count += 1
	# var min_dist = mini(wave_count, 5)
	# var spawn_points = path_finder.find_spawn_points(min_dist)
	demons_slain = 0
	spawn_count = 4 + wave_count
	var spawn_points = path_finder.find_spawn_points(1)
	if spawn_points.is_empty():
		# No valid spawns yet — skip wave
		GameEvents.wave_ended.emit()
		return
	var interval = maxf((1.0 / spawn_points.size()), 0.1)

	wave_active = true
	var demon_container = get_node("../GameBoard/DemonContainer")

	for i in spawn_count:
		print("Spawning ", i)
		var spawn_cell = spawn_points.pick_random()
		var path = path_finder.calculate_path(spawn_cell)
		var waypoints = path_finder.path_to_waypoints(path)

		# Stagger spawns with a timer
		get_tree().create_timer(i * interval).timeout.connect(
			_spawn_demon.bind(waypoints, demon_container)
		)

func _spawn_demon(waypoints: Array[Vector2], container: Node2D) -> void:
	var demon = demon_scene.instantiate()
	container.add_child(demon)
	demon.setup(waypoints)
	GameEvents.demon_spawned.emit(demon)

func _on_demon_removed(_demon) -> void:
	if not wave_active:
		return
	demons_slain += 1
	print("killed ", demons_slain)
	if demons_slain >= spawn_count:
		wave_active = false
		GameEvents.wave_ended.emit()
