class_name Goon
extends CharacterBody2D #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)class_name Goon

class Commands:
	var walk: float
	# and obviously whatever else we end up needing

var bounds_size = 60
func get_bounds() -> Rect2:
	return Rect2(
		global_position - Vector2.ONE * bounds_size,
		Vector2.ONE * bounds_size * 2
	)

func _input(ev: InputEvent):
	pass

func identify(lines = []):
	for s in [
		"\nI am %s" % name
	] + lines:
		if s:
			print(s)

func _input_event(viewport: Node, ev: InputEvent, shape_idx: int):
	if ev.is_action_pressed("probe"):
		identify()

func command(commands: Commands) -> void:
	pass

var master: Master
func under_new_management(m: Master):
	master = m
