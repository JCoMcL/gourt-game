extends Area2D

@export var actors: Array[Actor]

class Line:
	var text: String
	var speaker: Actor
	func _init(text: String, speaker: Node2D):
		self.text = text
		self.speaker = speaker
		
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
	var line: Line = lines[counter]
	print("%s: %s" % [line.speaker.name, line.text])

	if ! speech_bubble:
		speech_bubble = SpeechTherapist.say(line.speaker, line.text)
		speech_bubble.auto_expire = false
		speech_bubble.on_done_showing.connect(display_line)
	else:
		speech_bubble.reset_text(line.text)
		speech_bubble.speaker = line.speaker
	speech_bubble.anneal_position(10)

	counter += 1
	if counter == lines.size():
		speech_bubble.on_done_showing.disconnect(display_line)
		speech_bubble.auto_expire = true

func activate():
	if lines.size() > 0:
		display_line()
	else:
		print("No lines to display.")
