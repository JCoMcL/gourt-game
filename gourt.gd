extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
enum Direction {LEFT, RIGHT}
var facing = 0

func _physics_process(delta: float) -> void:
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var target = Input.get_axis("go left","go right") * 200
	if target != 0:
		$Body.play("transportative")
		var t_facing = Direction.RIGHT if target > 0 else Direction.LEFT
	
		if t_facing != facing:
				flip()
				facing = t_facing
	else:
		$Body.play("idleative")

	velocity.x = move_toward(velocity.x, target, 20)

	move_and_slide()


func flip():
	transform.x *= -1
