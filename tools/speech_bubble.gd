@tool
extends Control
class_name SpeechBubble

@export var text: String = "Hello, World!":
	set(value):
		text = value
		if label:
			label.text = value
			update_size()

@export var speaker: Node2D

@onready var label = $Label

func _ready():
	update_size()
	
func update_size():
	if ! label:
		print("tried to call update_size too early")
		return
	var font = label.get_theme_font("font")
	if font:
		var text_line = TextLine.new()
		text_line.add_string(label.text, font, label.get_theme_font_size("normal_font_size"))
		var text_size = text_line.get_size()
		var stylebox = get_theme_stylebox("panel")
		size = text_size
		label.size = text_size
