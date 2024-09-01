extends StaticBody3D

var bullet: PackedScene = preload("res://scenes/towers/arrow.tscn")
var bullet_damage: int = 5
var firerate : float = 1.0
var targets: Array = []
var current_target : CharacterBody3D
var can_shoot : bool = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(current_target):
		look_at(current_target.global_position)
		if can_shoot:
			shoot()
			can_shoot = false
			$ShotCooldown.start()
	else:
		for i in get_node("BulletContainer").get_child_count():
			get_node("BulletContainer").get_child(i).queue_free()
	
func shoot() -> void:
	var _bullet : CharacterBody3D = bullet.instantiate()
	_bullet.target = current_target
	_bullet.damage = bullet_damage
	get_node("BulletContainer").add_child(_bullet)
	_bullet.global_position = $"Unit-wall-tower/Marker3D".global_position
	
func set_current_target(_targets: Array) -> void:
	var temp_array : Array = _targets
	var _current : CharacterBody3D = null
	for i in temp_array:
		if _current == null or i.get_parent().get_progress() > current_target.get_parent().get_progess():
			current_target = i
			print(current_target)

func _on_mob_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		targets.append(body)
		set_current_target(targets)


func _on_mob_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		targets.erase(body)
		set_current_target(targets)


func _on_shot_cooldown_timeout() -> void:
	can_shoot = true
