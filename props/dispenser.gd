extends Area2D

@export var output: PackedScene = null

func interact(operator) -> bool:
	var o = output.instantiate()
	return o.interact(operator) #Note this would only work with an equippable operator
