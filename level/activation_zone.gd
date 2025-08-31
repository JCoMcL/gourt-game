extends Area2D

@onready var parent: Camera2D = get_parent()
@onready var initial_size: Vector2 = $CollisionShape2D.shape.size

func _physics_process(delta: float) -> void:
	$CollisionShape2D.shape.size = initial_size / parent.zoom
