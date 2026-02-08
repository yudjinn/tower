class_name Demon
extends Node2D

@export var max_health: float = 100.0
@export var speed: float = 100.0

var health: float = max_health
var waypoints: Array[Vector2] = []
var waypoint_index: int = 0

func _ready():
	$HitArea.collision_layer = 2   # on layer 2
	$HitArea.collision_mask = 0     # doesn't detect anything
	$HitArea.monitoring = false
	$HitArea.monitorable = true     # can be detected by towers


func setup(path: Array[Vector2]) -> void:
	waypoints = path
	if waypoints.size() > 0:
		position = waypoints[0]
	queue_redraw()

func _process(delta: float) -> void:
	if waypoint_index >= waypoints.size():
		return

	var target = waypoints[waypoint_index]
	var move_distance = speed * delta
	var to_target = target - position

	if to_target.length() <= move_distance:
		position = target
		waypoint_index += 1
		if waypoint_index >= waypoints.size():
			reached_goal()

	else:
		position += to_target.normalized() * move_distance

func take_damage(amount: float) -> void:
	health -= amount
	queue_redraw()
	if health <= 0:
		GameEvents.demon_killed.emit(self)
		queue_free()

func reached_goal() -> void:
	GameEvents.demon_reached_goal.emit(self)
	queue_free()

func _draw() -> void:
	# Green circle body
	draw_circle(Vector2.ZERO, 8.0, Color.GREEN)

	# Health bar background
	var bar_width = 20.0
	var bar_height = 3.0
	var bar_pos = Vector2(-bar_width / 2, -14)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.DARK_RED)

	# Health bar fill
	var fill_width = bar_width * (health / max_health)
	draw_rect(Rect2(bar_pos, Vector2(fill_width, bar_height)), Color.GREEN)
