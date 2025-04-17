@tool
extends Node2D

@export var gourt: PackedScene
var children = []
@export_tool_button("Add", "Add") var fa = func add_to_stack():
	var child = gourt.instantiate()
	child.name = "Gourt{0}".format([len(children)])
	add_child(child)
	child.set_owner(self)
	children.append(child)
@export_tool_button("Remove", "Remove") var fr = func remove_from_stack():
	for child in children:
		child.queue_free()

func unleash_children():
	pass

func _ready() -> void:
	if not Engine.is_editor_hint:
		unleash_children()

func _process(delta: float) -> void:
	pass
