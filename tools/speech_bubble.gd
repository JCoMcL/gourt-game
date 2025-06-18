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
		print("tried to call update_size too early!")
		return
	var font = label.get_theme_font("font")
	if font:
		var text_line = TextLine.new()
		text_line.add_string(label.text, font, label.get_theme_font_size("normal_font_size"))
		var text_size = text_line.get_size() * 1.02 #FIXME calculation is slightly undersized.
		size = text_size
		label.size = text_size

func offset_to(v: Vector2):
	return v - global_position

var position_goals = [
	func antigravity():
		return global_position + Vector2.UP * size.y * 20,
	func near_speaker():
		if speaker:
			return speaker.global_position
		return Vector2.ZERO
	# on-screen
	# away from other actors
	# not overlapping speaker
	# not overlapping gourts
]

var velocity = Vector2.ZERO
func _physics_process(delta: float) -> void:
	for g in position_goals:
		position += offset_to(g.call()) * delta
