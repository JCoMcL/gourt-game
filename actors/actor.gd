extends Goon
class_name Actor

var active_command: Goon.Commands = null

@export var speed = 300.0
@export var gravity = 900.0
@export var social_distance = 20.0
@export var facing = 0

var target

enum Direction {LEFT, RIGHT}

func get_mouth():
	return get_node("Sprite2D/Handle/Speak Hole")

func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer(k.get_collider_rid()) & Clision.layers["special solid"]

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
	velocity.x = speed * direction

func die():
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO

func flip():
	transform.x *= -1

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
	velocity.y += gravity * delta
	if target:
		move_to_target()
	for i in range(get_slide_collision_count()):
		var k = get_slide_collision(i)
		if is_special_collision(k):
			die()
	move_and_slide()
