extends Area2D
var open_state = false

func open():
	if not open_state:
		open_state = true
		monitorable = true
		$AnimationPlayer.play("opening")

func close():
	if open_state:
		open_state = false
		monitorable = false
		$AnimationPlayer.play("closing")

func interact(operator: Node) -> bool:
	operator.reparent($Frame/Interior/Background)
	close()
	return true
