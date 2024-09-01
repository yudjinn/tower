extends CharacterBody3D


@export var speed: int = 2
@export var health: int = 10

@onready var path : PathFollow3D = get_parent()

func _ready() -> void:
	$Skeleton_Minion/AnimationPlayer.play("Walking_A")

func _physics_process(delta: float) -> void:
	path.set_progress(path.get_progress() + speed * delta)
	
	if path.get_progress_ratio() >= 0.99:
		path.queue_free()

func take_damage(_damage: int) -> void:
	health -= _damage
	if health <= 0:
		queue_free()
