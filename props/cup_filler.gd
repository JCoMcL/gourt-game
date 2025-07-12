extends Area2D

@export var output: PackedScene = null
@export var interactive_items = ['Cup']

func interact(operator):
	if operator.name not in interactive_items:
		return false
	Yute.replace_node(operator, output, operator.get_parent())
	return true
