extends Area2D

@export var actors: Array[Actor]
@export var equippables: Array[Equippable]

class Line:
	var text: String
	var speaker: Actor
	func _init(text: String, speaker: Node2D):
		self.text = text
		self.speaker = speaker

@onready var lines = [ 
    Line.new("Hey there.", actors[0]),
	Line.new("Buddy.", actors[0]),
	Line.new("Don't mind my...", actors[0]),
	Line.new("COOL.", actors[0]),
	Line.new("...", actors[0]),
	Line.new("...", actors[0]),
	Line.new("...", actors[0]),
    Line.new("*muffled brochure sounds*", actors[0]),
    Line.new("Here to get a job of your dream?", actors[0]),
    Line.new("...", actors[0]),
    Line.new("There is interview.", actors[0]),
    Line.new("*muffled journal-flipping sounds*", actors[0]),    
    Line.new("I am afraid.", actors[0]),
    Line.new("Of stress factors of interview with my future potential employer. This is normal since everyone is stressed of: public talking, uncomfortable chairs and dominant males.", actors[0]),
    Line.new("It is suggested to: stay hydrated and take prescribed medication.", actors[0]),
    Line.new("*Sounds of instruction unfolding*", actors[0]),
	Line.new("Sildenafil 500 'em-gee'.", actors[0]),
	Line.new("Take with water.", actors[0]),
    Line.new("*Opens up letter*.", actors[0]),
    Line.new("Hey dear, I am getting old.", actors[0]),
    Line.new("Who would give a glass of water for an old woman?", actors[0]),
    Line.new("I need you.", actors[0]),
    Line.new("I need.", actors[0]),
    Line.new("Water.", actors[0]),
    #actors[0].interact(equippables[0]),    
	actors[1].exit_stage_right
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
	elif line is Callable:
		await line.call()
		display_line()


func _ready():
	display_line.call_deferred()
