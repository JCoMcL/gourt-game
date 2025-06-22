extends Node
class_name Transactor
# Transactor is a node that can replace itself with another node when interacted with.

@export var required_input: bool = false
@export var required_output: bool = false
@export var input = null
@export var output: PackedScene = null

func interact(operator):
	if input:
		Gourtilities.replace_node(input, output, operator)
	else:
		var o = output.instantiate()
		o.global_position = operator.global_position
		print(o.name, " instantiated at ", o.global_position)
		operator.interact(o)
