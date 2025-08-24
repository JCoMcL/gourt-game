extends Area2D
var open_state = false

func open():
	if not open_state:
		open_state = true
		update_state()
		$AnimationPlayer.play("opening")

func close():
	if open_state:
		open_state = false
		$AnimationPlayer.play("closing")

func update_state():
	collision_layer = Clision.layers["door"] * int(open_state)

func on_animation_finished(anim_name: StringName):
	update_state()

func _ready():
	update_state()
	$AnimationPlayer.animation_finished.connect(on_animation_finished)

func interact(operator: Node) -> bool:
	operator.reparent($Frame/Interior/Background)
	close()
	return true
