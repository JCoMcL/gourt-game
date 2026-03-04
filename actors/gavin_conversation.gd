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
		Line.new("Hotline? More like... HOT MESS.", actors[0]),
		Line.new("Did you see the conditions in here?", actors[0]),
		Line.new("This place is absolutely unacceptable!", actors[0]),
		Line.new("I'm writing this up for the building inspector.", actors[0]),
	]
	
	if autostart:
		start()
	else:
		area_entered.connect(on_activation_zone_entered)
