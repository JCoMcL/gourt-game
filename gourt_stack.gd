@tool
extends Node2D

@export var gourt: PackedScene
@export var root_child: Gourt

@export_tool_button("Add", "Add") var fa = func add_to_stack():
	var child = add_gourt()
	if not root_child:
		root_child = child
	else:
		Gourtilities.stack_now(child, root_child)
	child.name = "Gourt{0}".format([Gourtilities.head_count(root_child)])
@export_tool_button("Subtract", "CurveConstant") var fr = func remove_from_stack():
	rm_gourt(Gourtilities.get_stack_tip(root_child))
@export_tool_button("Reset", "Reload") var fre = func refresh_children():
	root_child = null
	for c in get_children():
		c.queue_free()

func add_gourt() -> Gourt:
	var child = gourt.instantiate()
	add_child(child)
	child.set_owner(get_tree().edited_scene_root)
	return child

#perhaps some of these should be moved into gourt.gd
func rm_gourt(g: Gourt):
	if g.foot_friend:
		g.foot_friend.head_friend = null
	if g.head_friend:
		g.head_friend.foot_friend = null
	g.queue_free()

func unleash_children():
	pass

func _ready() -> void:
	if not Engine.is_editor_hint:
		unleash_children()

func _process(delta: float) -> void:
	pass
