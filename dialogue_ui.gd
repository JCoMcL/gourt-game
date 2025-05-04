extends CanvasLayer
class_name DialogueUI

@onready var label_node = $Label

func show_text_at(world_position: Vector2, text: String):
	print(text)
	var screen_pos = get_viewport().get_camera_2d().get_screen_transform() * (world_position + Vector2(-1600, +50)) #Magic numbers to demagic
	label_node.text = text
	label_node.global_position = screen_pos
	label_node.visible = true

func hide_text():
	label_node.visible = false
