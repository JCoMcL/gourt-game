@tool
extends Line2D
class_name Disguise

@export var persona_actor: PackedScene
var persona: Actor

@export var back_texture: Texture2D:
	set(tex):
		back_texture = tex
		if is_node_ready():
			setup_back()

@export var foiled = false:
	set(b):
		if foiled != b:
			foiled = b
			_on_foiled_changed()

var front: Line2D
var back: Line2D
var plus_z: int = 4

func get_wearer() -> Gourt:
	var n = get_parent()
	if n is Gourt:
		return n
	return null

func _on_foiled_changed():
	for g in Gourtilities.list_stack_members(get_wearer()):
		g.visible = foiled
	if not foiled and not persona and persona_actor:
		persona = persona_actor.instantiate()
		if get_wearer():
			Gourtilities.get_stack_base(get_wearer()).add_child(persona)
			persona.reparent(get_wearer().get_parent())
		#persona.
	if persona:
		persona.visible = not foiled
		persona.scale = Vector2.ONE * 1.2 #HACK

func add_point_from(o: Node2D):
	add_point(to_local(o.global_position))

func setup_back():
	if not back_texture:
		return null
	back = get_node_or_null("Back")
	if not back:
		back= Line2D.new()
		add_child(back)
	back.width = width
	back.texture = back_texture
	back.material = material
	back.points = points
	if get_wearer():
		back.z_index = Gourtilities.get_stack_base(get_wearer()).z_index -plus_z #BM2

func _ready():
	setup_back()
	_on_foiled_changed.call_deferred()

const persona_offset = Vector2(0, 60)
func _physics_process(delta:float):
	var wearer = get_wearer()
	if not wearer or not is_instance_valid(wearer):
		return
	if not foiled and persona and wearer:
		persona.position = Gourtilities.get_stack_base(wearer).position + persona_offset

func _process(delta: float) -> void:
	var wearer = get_wearer()
	if not wearer or not is_instance_valid(wearer):
		return

	if wearer == get_parent():
		z_index = plus_z
		z_as_relative = true
		transform.x = wearer.transform.x # Hack to unflip self if parent flips
	else:
		z_as_relative = false
		z_index = Yute.get_canvas_item_global_z(wearer) + plus_z

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
