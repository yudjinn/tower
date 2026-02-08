extends Node2D

var target: Node2D
var damage: float
var speed: float = 300.0

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	var to_target = target.global_position - global_position
	if to_target.length() <= speed * delta:
		target.take_damage(damage)
		queue_free()
	else:
		global_position += to_target.normalized() * speed * delta

func _draw() -> void:
	# Small white line in movement direction
	draw_line(Vector2.ZERO, Vector2(8, 0), Color.WHITE, 2.0)
