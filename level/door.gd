extends Area2D

class_name Door
@export var exit: Door

func interract(operator):
	operator.global_position += exit.global_position - global_position 
