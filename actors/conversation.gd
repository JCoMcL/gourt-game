extends Area2D

@export var actors: Array[Actor]
@export var autostart = false

class Line:
	var text: String
	var speaker: Actor
	func _init(text: String, speaker: Node2D):
		self.text = text
		self.speaker = speaker

@onready var keith=actors[0]
@onready var janet=actors[1]
@onready var janny=actors[2]

@onready var lines = [ Line.new("Look at that.", janet),
	Line.new("This a seems like a violation of workplace safety code.", janet),
	Line.new("29 CFR 1910.212", keith),
	Line.new("Not to mention 1910.36(b)(1).", janet),
	Line.new("So true!", keith),
	Line.new("Oh my! That does sound quite unsafe.", janny),
	Line.new("We'll need to bring this finding to the owner the building at once.", janet),
	Line.new("The Boss. His office is that way.", janny),
	Line.new("Thank you for your cooperation", keith),
	keith.exit_stage_right,
	janet.exit_stage_right
]

var counter = 0
var speech_bubble: SpeechBubble
func display_line():
	if counter >= lines.size():
		if speech_bubble:
			speech_bubble.queue_free()
		return

	var line = lines[counter]
	counter += 1

	if line is Line: # Yeah, I know this is confusing
		print("%s: %s" % [line.speaker.name, line.text])

		if ! speech_bubble:
			speech_bubble = SpeechTherapist.say(line.speaker, line.text)
			speech_bubble.auto_expire = false
			speech_bubble.on_done_showing.connect(display_line)
		else:
			speech_bubble.reset_text(line.text)
			speech_bubble.speaker = line.speaker
		speech_bubble.anneal_position()
		line.speaker.begin_speaking.call_deferred()
		speech_bubble.on_done_showing.connect(line.speaker.stop_speaking, Node.CONNECT_ONE_SHOT)
	elif line is Callable:
		await line.call()
		display_line()

var started = false
func start():
	if started:
		return
	started = true
	display_line.call_deferred()

func on_activation_zone_entered(area: Area2D):
	start()

func _ready():
	if autostart:
		start()
	else:
		area_entered.connect(on_activation_zone_entered)
