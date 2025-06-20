@tool
extends Sprite2D
class_name Actor

func get_mouth():
	var m = get_node_or_null("Handle/Speak Hole")
	if not m:
		print("yo, speak hole is broken, fix that shit") # high quality testing
	return m
