class_name Goon
extends CharacterBody2D #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)class_name Goon

class Commands:
	var walk: float
	# and obviously whatever else we end up needing

func command(commands: Commands) -> void:
	pass

var master: Master
func under_new_management(m: Master):
	master = m
