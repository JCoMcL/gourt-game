@tool
extends Goon
class_name Actor

@export var move := false
@export var move_speed := 0
@export var fall_speed := 1
@export var mass = 20

func get_mouth():
	return get_node("Handle/Speak Hole")

func exit_stage_right():
	move = true
	move_speed = 200

func exit_stage_left():
	move = true
	move_speed = -200

func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer( k.get_collider_rid() ) & Clision.layers["special solid"]

func die():
	collision_layer = 0
	collision_mask = 0
	move_speed = 0 
	fall_speed = 40 # Dramatic fall

func _physics_process(delta):
	if move:
		position.x += move_speed * delta
		position.y += fall_speed
		print("moving", position, move_speed, get_gravity().y)
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var k = get_slide_collision(i)
		if is_special_collision(k):
			die()
