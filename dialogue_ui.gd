extends CanvasLayer
class_name DialogueUI

@onready var label_node = $RichTextLabel

func show_text_at(world_position: Vector2, text: String):
	print(text)
	var screen_pos = (world_position) #Magic numbers to demagic get_viewport().get_camera_2d().get_screen_transform() * 
	label_node.text = text
	label_node.global_position = screen_pos
	label_node.visible = true

func hide_text():
	label_node.visible = false

func draw_line(start: Vector2, end: Vector2, color: Color):
	var line = Line2D.new()
	line.points = [start, end]
	line.width = 2
	line.default_color = color
	add_child(line)
