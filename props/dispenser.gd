extends Area2D

@export var output: PackedScene = null

func interact(operator):
	var o = output.instantiate()
	o.interact(operator) #Note this would only work with an equippable operator
