extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
enum Direction {UP, DOWN, LEFT, RIGHT}
@export var facing = Direction.LEFT
var foot_friend: CharacterBody2D

func _ready() -> void:
	$Gaura.area_entered.connect(gaura_detect)
	$Gaura.body_entered.connect(gaura_detect)

func _physics_process(delta: float) -> void:
	var target : Vector2
	if foot_friend:
		target = offset_to(foot_friend) + Vector2.UP * 70
	else:
		target.x = Input.get_axis("go left","go right") * 200
		# Add the gravity.
		if not is_on_floor():
			target += get_gravity() * delta

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if target.x != 0:
			$Body.play("transportative")
			var t_facing = Direction.RIGHT if target.x > 0 else Direction.LEFT
		
			if t_facing != facing:
					flip()
					facing = t_facing
		else:
			$Body.play("idleative")
			
	velocity = velocity.move_toward(target, 20)
	print(target, velocity)
	move_and_slide()

func gaura_detect(detected_gaura: Node2D):
	if get_direction(offset_to(detected_gaura)) == Direction.DOWN:
		foot_friend = detected_gaura.get_parent()

func pretty_direction(i:int):
	if(i == Direction.UP):
		return "UP"
	if(i == Direction.DOWN):
		return "DOWN"
	if(i == Direction.RIGHT):
		return "RIGHT"
	if(i == Direction.LEFT):
		return "LEFT"
		
func offset_to(body: Node2D):
	return body.global_position - global_position

func test_spread(f: float, within: float, of: float) -> bool:
	return (of - within) < f and f < (of + within)

func get_direction(to: Vector2):
	var angle = rad_to_deg(to.angle()) + 155
	if test_spread(angle, 30, 65):
		return Direction.UP
	if test_spread(angle, 20, 155):
		return Direction.RIGHT
	if test_spread(angle, 30, 245) :
		return Direction.DOWN
	if test_spread(angle, 20, 340):
		return Direction.LEFT
	print("get_direction returned nothing")

func flip():
	transform.x *= -1
