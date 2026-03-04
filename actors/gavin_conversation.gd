extends Area2D

@export var actors: Array[Actor]
@export var autostart = false

class Line:
	var text: String
	var speaker: Actor
	func _init(text: String, speaker: Node2D):
		self.text = text
		self.speaker = speaker

var lines: Array

var counter = 0
var speech_bubble: SpeechBubble

func zoom_to_gavin() -> void:
	"""Fade out, zoom in on Gavin's face, flash, then fade back in"""
	var camera = get_viewport().get_camera_2d()
	if not camera:
		print("ERROR: Could not find camera!")
		return
	
	print("Found camera, starting zoom sequence")
	
	# Disable camera tracking temporarily
	var old_player = camera.player_character
	camera.player_character = null
	
	# Create fade overlay
	var fade = CanvasLayer.new()
	fade.layer = 99
	get_tree().root.add_child(fade)
	
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate.a = 0.0
	rect.anchor_left = 0
	rect.anchor_top = 0
	rect.anchor_right = 1
	rect.anchor_bottom = 1
	fade.add_child(rect)
	
	# Fade to black
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, 0.05)
	
	# Zoom in hard on Gavin while faded (in parallel with fade)
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(camera, "zoom", Vector2(10.0, 10.0), 0.1)
	zoom_tween.tween_property(camera, "global_position", actors[0].global_position + Vector2(0, -250), 0.1)
	
	# Quickly fade back in to see his face
	tween.tween_property(rect, "modulate:a", 0.0, 0.05)
	
	await tween.finished
	
	# Wait 2 seconds watching his face
	await get_tree().create_timer(2.0).timeout
	
	# Flash (will complete internally with queue_free)
	flash_teeth()
	# Wait for flash duration (0.05 + 0.3 + 0.1 = 0.45 seconds)
	await get_tree().create_timer(0.45).timeout
	
	# Fade back out
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(rect, "modulate:a", 0.0, 0.15)
	await fade_tween.finished
	fade.queue_free()
	
	# Reset camera zoom back to normal before re-enabling tracking
	camera.zoom = Vector2.ONE
	
	# Re-enable camera tracking
	camera.player_character = old_player
	
	# Wait a frame for camera to catch up
	await get_tree().process_frame
	
	# Reposition any existing speech bubble to account for the zoom change
	if speech_bubble:
		speech_bubble.anneal_position(20)

func flash_teeth() -> void:
	"""Create a white flash effect on Gavin's teeth"""
	var flash = CanvasLayer.new()
	flash.layer = 100
	get_tree().root.add_child(flash)
	
	var rect = ColorRect.new()
	rect.color = Color.WHITE
	rect.modulate.a = 0.0
	rect.anchor_left = 0
	rect.anchor_top = 0
	rect.anchor_right = 1
	rect.anchor_bottom = 1
	flash.add_child(rect)
	
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "modulate:a", 0.6, 0.05)
	tween.tween_interval(0.3)
	tween.tween_property(rect, "modulate:a", 0.0, 0.1)
	tween.tween_callback(flash.queue_free)

func display_line():
	if counter >= lines.size():
		if speech_bubble:
			speech_bubble.queue_free()
		return

	var line = lines[counter]
	counter += 1

	if line is Line:
		print("%s: %s" % [line.speaker.name, line.text])

		if ! speech_bubble:
			speech_bubble = SpeechTherapist.say(line.speaker, line.text)
			speech_bubble.auto_expire = false
			speech_bubble.on_done_showing.connect(display_line)
		else:
			speech_bubble.reset_text(line.text)
			speech_bubble.speaker = line.speaker
		speech_bubble.anneal_position()
	elif line is Callable:
		await line.call()
		display_line()

var started = false
func start():
	if started:
		return
	started = true
	await get_tree().process_frame
	display_line()

func on_activation_zone_entered(area: Area2D):
	start()

func _ready():
	lines = [
		Line.new("Oi! A fresher!", actors[0]),
		Line.new("Welcome-welcome!", actors[0]),
		Line.new("I am Gavin, your new supervisor!", actors[0]),
		Line.new("On your first 10 years here you will be working in the hotline!", actors[0]),
		Line.new("Hotline? More like... HOT MESS.", actors[0]),
		zoom_to_gavin,
		Line.new("You will love it here!", actors[0]),
		Line.new("Your seat number is an unlabeled seat next to seat no. 564825930682672412489124", actors[0]),
		Line.new("The lights are not working there, so it is easy to find.", actors[0]),
		Line.new("Oh, you also gotta change them lights.", actors[0]),
		Line.new("The instructions are sent to your work internet mailbox.", actors[0]),
	]
	
	if autostart:
		start()
	else:
		area_entered.connect(on_activation_zone_entered)
