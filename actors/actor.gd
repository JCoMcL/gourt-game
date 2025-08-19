extends Goon
class_name Actor

var active_command: Goon.Commands = null

@export var social_distance = 20.0

var target

func get_mouth():
	return get_node("Sprite2D/Handle/Speak Hole")

func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer(k.get_collider_rid()) & Clision.layers["special solid"]

func exit_stage_left():
	target = Vector2(-INF, 0)
func exit_stage_right():
	target = Vector2(INF, 0)

func _process(delta):
	if command_queue.size() > 0:
		print("Processing command queue: %d commands" % command_queue.size())
		if !active_command:
			active_command = command_queue.pop_front()
			execute(active_command)

func move_to_target():
	var dx = target.x - global_position.x
	if abs(dx) < social_distance:
		velocity.x = 0
		target = null
		return
	var direction = sign(dx)
	var t_facing = Direction.RIGHT if direction > 0 else Direction.LEFT
	if t_facing != facing:
		flip()
		facing = t_facing
	velocity.x = walk_speed * direction

func execute(command: Goon.Commands):
	print("Executing command of type: %s" % command.type)
	match command.type:
		"wait":
			pass
		"walk_to":
			print("Walking to %s" % command.params.get("position", Vector2.ZERO))
			target = command.params.get("position", Vector2.ZERO)
			move_to_target()
		_:
			pass

func _physics_process(delta):
	if target:
		move_to_target()
	super(delta)
