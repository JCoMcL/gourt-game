class_name Goon
extends CharacterBody2D #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)

class Commands:
	var walk: float #only used by them pesky gourts!!! 
	var type: String
	var params: Dictionary
	# and obviously whatever else we end up needing

var bounds_size = 60 #TODO this is the gourt's size, and it's a guess
var command_queue: Array[Commands] = []

func get_rect() -> Rect2:
	## a Rect2 representing the boundary of the goon in local coordinates
	var r = get_global_rect()
	r.position -= global_position
	return r

func get_global_rect() -> Rect2:
	return Rect2(
		global_position - Vector2.ONE * bounds_size,
		Vector2.ONE * bounds_size * 2
	)

func _input(ev: InputEvent):
	pass

func _interact(what: Node, where: Vector2) -> bool:
	if what.has_method("interact"):
		return what.interact(self)
	return false

func say(s: String):
	SpeechTherapist.say(self, s)
	print(s) #TODO

func identify(lines = []):
	for s in [
		"\nI am %s" % name
	] + lines:
		if s:
			print(s)

func _input_event(viewport: Node, ev: InputEvent, shape_idx: int):
	if ev.is_action_pressed("probe"):
		identify()

func command(commands: Commands) -> void: #TODO make the parametric caommand the default command
	pass

func command_parametrically(cmd_type: String, params: Dictionary = {}):
	command_queue.append(Commands.new())
	command_queue[-1].type = cmd_type
	command_queue[-1].params = params

var master: Master
func under_new_management(m: Master):
	master = m
