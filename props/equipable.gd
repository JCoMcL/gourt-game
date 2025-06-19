extends Area2D

class_name Equippable

enum EquippableType { HEAD, EYES, HAND, FOOT }

@export_enum("HEAD", "EYES", "HAND", "FOOT")
var equippable_type: int = EquippableType.HEAD
var tween : Tween = null

func interract(operator):
	var target_slot: Node2D

	match equippable_type:
		EquippableType.HEAD:
			target_slot = operator.get_node("Body/HeadSlot")
		EquippableType.EYES:
			target_slot = operator.get_node("Body/Face/EyesSlot")
		EquippableType.HAND:
			target_slot = operator.get_node("Body/HandSlot1") #TODO think about left/right hands/legs
		EquippableType.FOOT:
			target_slot = operator.get_node("Body/LegSlot1")
		_:
			return

	global_position = target_slot.global_position
	reparent(target_slot)

	position = Vector2.ZERO

func set_selected(is_selected: bool):
	if is_selected:
		flash()
	else:
		stop_flash()

func flash():
	if tween:
		tween.kill()
		tween = null		
	tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 0.3, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func stop_flash():
	if tween:
		tween.kill()
		tween = null
	modulate = Color(1, 1, 1, 1)
