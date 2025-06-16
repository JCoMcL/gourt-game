extends Area2D

class_name Equippable

enum EquippableType { HEAD, EYES, HAND, FOOT }

@export_enum("HEAD", "EYES", "HAND", "FOOT")
var equippable_type: int = EquippableType.HEAD

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
