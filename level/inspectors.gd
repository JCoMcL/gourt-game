extends Actor
@export var targets: Array[Node] = []
var act = 0
func _ready():
	scenario = [
		func():
			target = targets[0],
		func():
			target = targets[1]
			interact = true
	]

func _physics_process(delta):
	super._physics_process(delta)
	if not target and act < scenario.size():
		scenario[act].call()
		act += 1
