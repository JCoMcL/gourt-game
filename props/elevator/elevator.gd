extends Area2D

@export var level_to: PackedScene
@export var entrypoint: NodePath

var open_state = false #TODO work will be needed to allow door to start open
@onready var waiting_area: Node = $Frame/Interior/Background

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

func boot_passengers():
	if waiting_area.get_children():
		for o in waiting_area.get_children():
			o.reparent(get_parent())
			o.reset_physics_interpolation()
		close()

func on_animation_finished(anim_name: StringName):
	update_state()
	if anim_name == "closing":
		var a = waiting_area.get_children()
		for o in a:
			if o is Actor and o.master:
				a.append(o.master)
		if a:
			# TODO it should be the player who triggers the level transition, not the door. This allows NPCs to use the elevator and softlock the game
			Yute.get_level_container(self).transition_to(level_to, a, entrypoint)
	if anim_name == "opening":
		boot_passengers()

func _ready():
	update_state()
	$AnimationPlayer.animation_finished.connect(on_animation_finished)
	if waiting_area.get_children():
		open()

func interact(operator: Node) -> bool:
	operator.reparent(waiting_area)
	operator.reset_physics_interpolation()
	close()
	return true
