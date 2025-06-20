extends Area2D

@export var actors: Array[Node2D] # List of actors involved in the conversation
@export var speed: float = 0.1 # Speed of the text display in characters per second
var counter = 0

class Line:
	var text: String
	var speaker: Node2D
	func _init(text: String, speaker: Node2D):
		self.text = text
		self.speaker = speaker
	
	func display():
		# This function could be used to display the line in the game UI.
		# For now, we will just print it to the console.
		print("%s: %s" % [speaker.name, text])
	
	func duration() -> float:
		# Calculate the duration based on the length of the text and speed
		return text.length() / 20 + 0.2


@onready var lines = [ Line.new("Look at that.", actors[0]),
	Line.new("This a seems like a violation workplace safety code.", actors[0]),
	Line.new("29 CFR 1910.212", actors[0]),
	Line.new("Not to mention 1910.36(b)(1).", actors[0]),
	Line.new("So true!", actors[0]),
	Line.new("Oh my! That does sound quite unsafe.", actors[1]),
	Line.new("We'll need to bring this finding to the owner the building at once.", actors[0]),
	Line.new("The Boss. His office is that way.", actors[1]),
	Line.new("Thank you for your cooperation", actors[0]),
]

func display_line():
	lines[counter].display()
	counter += 1
	if counter < lines.size():
		$Timer.start((lines[counter]).duration())


func _ready():
	print(speed)
	$Timer.timeout.connect(display_line)
	$Timer.one_shot = true

	if lines.size() > 0:
		display_line()
	else:
		print("No lines to display.")
