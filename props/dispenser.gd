extends Area2D

@export var output: PackedScene = null

func interract(operator):
	var o = output.instantiate()
	o.interract(operator) #Note this would only work with an equippable operator
