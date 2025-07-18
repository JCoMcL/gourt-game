extends Area2D

@export var interactive_items = ['Sunglasses']
@export var updated_output: PackedScene = null
@export var filler: Area2D = null

func interact(operator) -> bool:
	if operator.name in interactive_items:
		operator.interact(self)
		filler.output = updated_output
		return true
	else:
		return false
