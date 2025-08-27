@tool
extends Line2D

@export var wearer: Gourt

func _enter_tree():
	if get_parent() is Gourt:
		wearer = get_parent()

func add_point_from(o: Node2D):
	add_point(to_local(o.global_position))

func _process(delta: float) -> void:
	if not wearer or not is_instance_valid(wearer):
		return

	if wearer == get_parent():
		z_index = 0
		z_as_relative = true
	else:
		z_as_relative = false
		z_index = wearer.z_index + 1 #TODO calculate the wearer's global z_index

	clear_points()
	add_point_from(wearer.get_node("Perch"))
	add_point_from(wearer)
	for g in Gourtilities.list_foot_friends(wearer):
		add_point_from(g)

func _draw() -> void:
	material.set_shader_parameter("full_length_px", abs(points[0].y - points[-1].y))
