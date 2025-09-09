extends Area2D

@onready var parent: Camera2D = get_parent()
@onready var initial_size: Vector2 = $CollisionShape2D.shape.size


func reset_encompass():
	$CollisionShape2D.position = Vector2.ZERO
	$CollisionShape2D.shape.size = initial_size

func encompass(r: Rect2):
	reset_encompass()
	var new_rect = Yute.union_rect([Yute.get_global_rect(self), r])
	$CollisionShape2D.global_position = new_rect.get_center()
	$CollisionShape2D.shape.size = new_rect.size
