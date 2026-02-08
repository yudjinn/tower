class_name ArcherTower
extends TowerBase

var arrow_scene = preload("res://scenes/projectiles/arrow.tscn")


func fire() -> void:
	var arrow = arrow_scene.instantiate()
	arrow.target = current_target
	arrow.damage = tower_data.damage
	arrow.global_position = global_position
	get_tree().root.get_node("Main/GameBoard/ProjectileContainer").add_child(arrow)
