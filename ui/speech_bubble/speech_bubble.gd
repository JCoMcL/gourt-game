@tool
extends Control
class_name SpeechBubble

@export var text: String = "Hello, World!":
	set(value):
		text = value
		if label:
			label.text = value
			update_size()

@export var speaker: Actor
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
			var spk = speaker.get_mouth()
			if not spk:
				spk = speaker
			return centred(spk.global_position - Vector2(0, spk.get_rect().size.y / 2))
		return Vector2.ZERO #speech bubbles without speakers go to (0,0) as god intended
		,
	func on_screen():
		return global_position
	# optimal tail length
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

func screen_to_world(v):
	return get_viewport().global_canvas_transform.affine_inverse() * v
			
var colors = [0xce4b46, 0x477571, 0xd692a8, 0x77729d, 0x6585a0].map(func (i): return Color(i))
func _draw() -> void: #Hey andrey, if you're reading this, this helped like you wouldn't believe
	if Engine.is_editor_hint():
		for i in range(position_goals.size()):
			draw_circle(
				position_goals[i].call() - global_position,
				8.0, colors[i], true
			)
		var r = get_viewport().get_visible_rect()
		
		var start = screen_to_world(r.position)
		var end = screen_to_world(r.end)
		var wr = Yute.get_viewport_world_rect(self)
		if wr.has_point(global_position):
			print(global_position)
		wr.position -= global_position
		end -= global_position
		draw_polyline(
			PackedVector2Array([
				wr.position,
				Vector2(wr.position.x, wr.end.y),
				wr.end,
				Vector2(wr.end.x, wr.position.y),
				wr.position
			]),
			colors[1], 20
		)
