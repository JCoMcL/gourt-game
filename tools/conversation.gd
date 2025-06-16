extends Area2D

@export var actors: Array[Node2D]
@export var speech_bubble_scene: PackedScene
@export var speed: float = 0.1

class Line:
	var text: String
	var speaker: Node2D
	func _init(text: String, speaker: Node2D):
		self.text = text
		self.speaker = speaker
	
	func display(speech_bubble: SpeechBubble):
		print("%s: %s" % [speaker.name, text])
		speech_bubble.text = text
		var speaker_rect = speaker.get_rect()
		speech_bubble.position = speaker.global_position + Vector2(0, -speaker_rect.size.y / 2) # Position speech bubble above the actor
		
	func duration() -> float:
		return text.length() / 20.0 + 0.2

@onready var lines = [ Line.new("Look at that.", actors[0]),
	Line.new("This a seems like a violation of workplace safety code.", actors[0]),
	Line.new("29 CFR 1910.212", actors[0]),
	Line.new("Not to mention 1910.36(b)(1).", actors[0]),
	Line.new("So true!", actors[0]),
	Line.new("Oh my! That does sound quite unsafe.", actors[1]),
	Line.new("We'll need to bring this finding to the owner the building at once.", actors[0]),
	Line.new("The Boss. His office is that way.", actors[1]),
	Line.new("Thank you for your cooperation", actors[0]),
]

var counter = 0
var speech_bubble: SpeechBubble
func display_line():
	if ! speech_bubble:
		speech_bubble = speech_bubble_scene.instantiate()
		add_child(speech_bubble)
	lines[counter].display(speech_bubble)
	$Timer.start((lines[counter]).duration())
	counter += 1
	if counter == lines.size():
		$Timer.timeout.disconnect(display_line)
		$Timer.timeout.connect(speech_bubble.queue_free)

func _ready():
	print(speed)
	$Timer.timeout.connect(display_line)
	$Timer.one_shot = true	
	if lines.size() > 0:
		display_line()
	else:
		print("No lines to display.")
