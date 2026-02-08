class_name TowerBase
extends Area2D

var tower_data: TowerData
var facing_edge: int
var hovered: bool = false

var fire_timer: float = 0.0
var current_target: Node2D = null

func setup(data: TowerData, facing: int) -> void:
	tower_data = data
	facing_edge = facing
	$CollisionShape2D.shape.radius = data.range

func _ready() -> void:
	collision_layer = 0   # tower doesn't need to be detected
	collision_mask = 2     # monitors layer 2 (demons)
	monitoring = true      # detects others
	monitorable = false    # others don't detect it

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and tower_data:
		var mouse_pos = get_global_mouse_position()
		var was_hovered = hovered
		hovered = global_position.distance_to(mouse_pos) < 12.0
		if hovered != was_hovered:
			queue_redraw()

func _process(delta: float) -> void:
	if tower_data == null:
		return

	fire_timer -= delta
	current_target = find_nearest_target()

	if current_target and fire_timer <= 0:
		fire()
		fire_timer = tower_data.fire_rate

func find_nearest_target() -> Node2D:
	var closest: Node2D = null
	var closest_dist: float = INF

	for area in get_overlapping_areas():
		if area.get_parent() is Demon:
			var demon = area.get_parent()
			var dist = global_position.distance_to(demon.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = demon

	return closest

func fire() -> void:
	pass  # overridden by archer_tower

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color.RED)

	# Range ring
	if tower_data and hovered:
		draw_circle(Vector2.ZERO, tower_data.range, Color(1,0,0,0.15))
		draw_arc(Vector2.ZERO, tower_data.range, 0, TAU, 64, Color(1, 0, 0, 0.1), 1.0)
