extends Area2D

class_name Door
@export var exit: Door

func interact(operator):
	operator.global_position += exit.global_position - global_position
