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
@export var debug_overlays = false
@export var auto_expire = true:
	set(value):
		auto_expire = value
		if auto_expire:
			on_done_showing.connect(queue_free)
		else:
			on_done_showing.disconnect(queue_free)

@onready var label = $Label
@onready var timer = $Timer

signal on_done_showing() #emitted when the duration for the text based on Settings.text_speed runs out

func _ready():
	timer.timeout.connect(on_done_showing.emit)

	# trigger setters
	text = text
	auto_expire = auto_expire

	reset_timer()

func add_text(s: String):
	if text:
		text = text + " " + s
	else:
		text = s

	timer.start(timer.time_left + Settings.text_duration(s))

func reset_timer():
	timer.start(Settings.text_duration(text) + 1.0)

func reset_text(s: String):
	## set text and restart timer
	text = s
	reset_timer()
	
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

class Position_Goal:
	var f: Callable
	var weight: float
	func _init(f: Callable, weight=1):
		self.f = f
		self.weight = weight

	func calculate():
		return f.call()

var position_goals = [
	Position_Goal.new(func antigravity():
	return global_position + Vector2.UP * size.y * 3
	,1),

	Position_Goal.new(func near_speaker():
	if not speaker:
		return null
	var spk = speaker
	if "get_mouth" in speaker:
		var mouth = speaker.get_mouth()
		if mouth:
			spk = mouth

	var speaker_rect = spk.get_rect()
	return centred(speaker_rect.position + spk.global_position + Vector2(speaker_rect.size.x/2, 0))
	,1),

	Position_Goal.new(func on_screen():
	var r = get_rect().grow(32)
	r.position = global_position #TODO getting our own global rect reliably is more steps than this
	var screen_rect = Yute.get_viewport_world_rect(self)
	if screen_rect.encloses(r):
		return null #goal is satisfied
	return Yute.nearest_overlapping_position(r, screen_rect)
	,50)

	# optimal tail length
	# away from other actors
	# not overlapping speaker
	# not overlapping gourts
]

var velocity = Vector2.ZERO
func update_position(delta):
	var target_offset = Vector2.ZERO
	var total_weight = 0
	for g in position_goals:
		var tgt = g.calculate()
		if tgt is Vector2:
			target_offset += offset_to(tgt) * g.weight
			total_weight += g.weight

	if total_weight != 0:
		target_offset /= total_weight

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

func _process(delta: float) -> void:
	if debug_overlays:
		queue_redraw()
	if not Engine.is_editor_hint():
		update_position(delta)

func screen_to_world(v):
	return get_viewport().global_canvas_transform.affine_inverse() * v
			
var colors = [0xce4b46, 0x477571, 0xd692a8, 0x77729d, 0x6585a0].map(func (i): return Color(i))
func _draw() -> void:
	if debug_overlays:
		draw_polyline(
			Yute.four_corners(speaker.get_rect()).map(func(p):
			return p + speaker.global_position - global_position
			),
			Color("red")
		)

		for i in range(position_goals.size()):
			var pg = position_goals[i].calculate()
			if pg is Vector2:
				draw_circle(
					pg - global_position,
					8.0 * position_goals[i].weight,
					colors[i], true
				)
