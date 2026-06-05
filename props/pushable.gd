extends RigidBody2D

func _ready() -> void:
	print(collision_layer)
	collision_layer |= Clision.layers["interactive"]
	print(collision_layer)

func interact(operator: Node) -> bool:
	apply_impulse(
		(global_position - operator.global_position).normalized() * 500,
	)
	return true
