extends Area2D

class_name Equippable

enum EquippableType { HEAD, EYES, HAND, FOOT }

@export_enum("HEAD", "EYES", "HAND", "FOOT")
var equippable_type: int = EquippableType.HEAD
var tween : Tween = null

func interact(operator) -> bool:
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
			return false
	global_position = target_slot.global_position
	if target_slot.get_child_count() == 0:
		if self.get_parent():
			reparent(target_slot)
		else:
			target_slot.add_child(self)
	position = Vector2.ZERO
	return true

func rigor_mortis():
		var rb = RigidBody2D.new()
		rb.position = global_position
		rb.add_child($CollisionShape2D.duplicate(0))
		rb.collision_mask = Clision.layers["solid"]
		var parent = get_parent()
		if parent:
			parent.add_child(rb) # TODO: should add to the scene and shouldn't be connected to gourt
			rb.global_position = global_position
			reparent(rb)
			get_tree().create_timer(2.0).timeout.connect(rb.queue_free)
			return

func set_selected(is_selected: bool):
	if is_selected:
		flash()
	else:
		stop_flash()

func flash():
	if tween:
		tween.kill()		
	tween = get_tree().create_tween()
	tween.bind_node(self)
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 0.3, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func stop_flash():
	if tween:
		tween.kill()
		tween = null
	modulate = Color(1, 1, 1, 1)
