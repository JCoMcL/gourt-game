extends Actor

var lines = [
	"Hello eryone",
	"How are you",
	"Finesankyu",
	"I wish I was a bird"
]

func interact(operator) -> bool:
	match operator.name:
		&"Filled Cup":
			say("This is not cool enough")
		&"Coolest Filled Cup":
			say("Just right!")
		_:
			if lines.size() > 1:
				say(lines.pop_front())
			else:
				say(lines[0])

	return true

func _ready():
	interactive_items = ["Filled Cup", "Coolest Filled Cup"]
	collision_layer |= Clision.layers["player_wall"]
	%Sunglasses.interacted_with.connect(_on_glasses_pinched, CONNECT_ONE_SHOT)

func _on_glasses_pinched(thief:Node2D):
	say("My Glasses! I need them to see!")
