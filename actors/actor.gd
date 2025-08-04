@tool
extends Goon
class_name Actor

var speed = 300.0
var gravity = 900.0
var spcial_distance = 20.0
enum Direction {LEFT, RIGHT}
var facing = 0
var interact = false
var target
var scenario = []

func get_mouth():
	return get_node("Handle/Speak Hole")

func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer(k.get_collider_rid()) & Clision.layers["special solid"]

func die():
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO

func move_to_target():
	var dx = target.global_position.x - global_position.x
	if abs(dx) < spcial_distance:
		velocity.x = 0
		if interact:
			target.interact(self)
		target = null
		interact = false
		return
	var direction = sign(dx)
	var t_facing = Direction.RIGHT if direction > 0 else Direction.LEFT
	if t_facing != facing:
		flip()
		facing = t_facing
	velocity.x = speed * direction

func _physics_process(delta):
	velocity.y += gravity * delta
	if target:
		move_to_target()
	for i in range(get_slide_collision_count()):
		var k = get_slide_collision(i)
		if is_special_collision(k):
			die()
	move_and_slide()

func flip():
	transform.x *= -1
