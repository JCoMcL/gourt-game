@tool
extends Node2D

@export var gourt: PackedScene
@export var root_child: Gourt

@export_tool_button("Add", "Add") var fa = func add_to_stack():
	var child = add_gourt()
	if not root_child:
		root_child = child
	else:
		stack_onto(get_stack_tip(root_child), child)
	child.name = "Gourt{0}".format([child_count(root_child)])
@export_tool_button("Remove", "Remove") var fr = func remove_from_stack():
	rm_gourt(get_stack_tip(root_child))

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

func get_stack_tip(g: Gourt):
	if g.head_friend:
		return get_stack_tip(g.head_friend)
	return g

func child_count(g: Gourt):
	if g.head_friend:
		return 1 + child_count(g.head_friend)
	return 0

func stack_onto(bottom: Gourt, top: Gourt):
	top.foot_friend = bottom
	bottom.head_friend = top
	top.position = bottom.position + Vector2.UP * 100

func unleash_children():
	pass

func _ready() -> void:
	if not Engine.is_editor_hint:
		unleash_children()

func _process(delta: float) -> void:
	pass
