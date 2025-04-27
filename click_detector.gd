extends Area2D

var query = PhysicsPointQueryParameters2D.new()
func _ready() -> void:
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 4
	#input_event.connect(on_input_event)

func collider_distance_from_pointer(o):
	return (o.collider.global_position - query.position).length_squared()
func compare_distance(a,b):
	return collider_distance_from_pointer(a) < collider_distance_from_pointer(b)

func _input_event(viewport: Node, ev: InputEvent, shape_idx: int):
	if ev.is_action_pressed("probe"):
		get_parent().identify()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("probe"):
		query.position = get_global_mouse_position()
		var collision_objects = get_world_2d().direct_space_state.intersect_point(query)
		if not collision_objects.size():
			return

		collision_objects.sort_custom(compare_distance)

		var what = collision_objects.pop_front().collider
		what.click.emit()
		for col_obj in collision_objects:
			var c = col_obj.collider
			if c.input_pickable:
				c.nearby_click.emit(c.to_local(query.position), what)
				return
