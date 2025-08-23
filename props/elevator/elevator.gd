extends Sprite2D
var open_state = false
func open():
	if not open_state:
		open_state = true
		$AnimationPlayer.play("opening")

func close():
	if open_state:
		open_state = false
		$AnimationPlayer.play("closing")
