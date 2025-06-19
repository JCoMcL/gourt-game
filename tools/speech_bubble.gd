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
@export_tool_button("Step", "Play") var f = anneal_position

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
func centred(v: Vector2):
	return v + Vector2(-size.x, size.y) /2

var position_goals = [
	func antigravity():
		return global_position + Vector2.UP * size.y * 3
		,
	func near_speaker():
		if speaker:
			var spk = speaker.get_node_or_null("Handle/Speak Hole") #TODO this should definitely be a method on the speaker
			if not spk:
				spk = speaker
			return centred(spk.global_position - Vector2(0, spk.get_rect().size.y / 2))
		return Vector2.ZERO #speech bubbles without speakers go to (0,0) as god intended
	# on-screen
	# away from other actors
	# not overlapping speaker
	# not overlapping gourts
]

var velocity = Vector2.ZERO
func update_position(delta):
	var target_offset = Vector2.ZERO
	for g in position_goals:
		target_offset += offset_to(g.call())

	velocity += Yute.snap_force(
		velocity,
		target_offset,
		delta,
		300,
		0.2
	)
	position += velocity * delta

func anneal_position(iterations: int = 1, delta=0.5):
	for i in range(iterations):
		update_position(delta)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		update_position(delta)

var colors = [0xce4b46, 0x477571, 0xd692a8, 0x77729d, 0x6585a0].map(func (i): return Color(i))
func _draw() -> void: #Hey andrey, if you're reading this, this helped like you wouldn't believe
	if Engine.is_editor_hint():
		for i in range(position_goals.size()):
			draw_circle(
				position_goals[i].call() - global_position,
				8.0, colors[i], true
			)
