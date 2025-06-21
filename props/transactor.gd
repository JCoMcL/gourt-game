extends Node

@export var required_input: bool = false
@export var required_output: bool = false
@export var input: Node2D = null
@export var output: PackedScene = null

func interract(operator):
    transact(operator)


func transact(operator):
    Gourtilities.replace_node(input, output, operator)
    