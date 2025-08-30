@tool
extends Line2D

@export var wearer: Gourt
@export var back_texture: Texture2D:
	set(tex):
		back_texture = tex
		setup_back()

var back: Line2D
var plus_z: int = 4

func _enter_tree():
	if get_parent() is Gourt:
		wearer = get_parent()

func add_point_from(o: Node2D):
	add_point(to_local(o.global_position))

func setup_back():
		if back_texture:
			back = get_node_or_null("Back")
			if not back:
				return
			back.width = width
			back.texture = back_texture
			if wearer:
				back.z_index = Gourtilities.get_stack_base(wearer).z_index -plus_z #BM2
			back.material = material
			back.points = points
		else:
			back = null

func _ready():
	setup_back()

func _process(delta: float) -> void:
	if not wearer or not is_instance_valid(wearer):
		return

	if wearer == get_parent():
		z_index = plus_z
		z_as_relative = true
	else:
		z_as_relative = false
		z_index = wearer.z_index + plus_z #TODO calculate the wearer's global z_index

	clear_points()
	add_point_from(wearer.get_node("Perch"))
	add_point_from(wearer)
	for g in Gourtilities.list_foot_friends(wearer):
		add_point_from(g)
	if back:
		back.set_points(points)
		back.z_index = -Gourtilities.stack_count(wearer) - plus_z

func _draw() -> void:
	material.set_shader_parameter("full_length_px", abs(points[0].y - points[-1].y))
