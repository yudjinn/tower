extends Node3D


@onready var enemy: PackedScene = preload("res://scenes/mobs/minon.tscn")

var enemies_to_spawn : int = 10

var can_spawn : bool = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	game_manager()

func game_manager() -> void:
	if enemies_to_spawn > 0 and can_spawn:
		$SpawnTimer.start()
		
		var tempEnemy = enemy.instantiate()
		$Path3D.add_child(tempEnemy)
		enemies_to_spawn -= 1
		can_spawn = false
		
func _on_spawn_timer_timeout() -> void:
	can_spawn = true
