extends CharacterBody2D



enum Direction {UP, DOWN, LEFT, RIGHT}
@export var facing = Direction.LEFT
@export var gourt_name = "gourt" #For debug purposes, serves no gameplay value. TODO revise 

var disarray = false #Defines if gourts can be assembled in gourtstack
var foot_friend: CharacterBody2D

func _ready() -> void:
	$Gaura.area_entered.connect(gaura_detect)
	#$Gaura.body_entered.connect(gaura_detect)

func _physics_process(delta: float) -> void:
	var target : Vector2

	if Input.is_action_just_pressed("break stack"):
		print("gourt is in a disarray!")
		disarray = true
		foot_friend = null
		var rng = RandomNumberGenerator.new()
		target.x = rng.randf_range(-10000.0, 10000.0) #TODO implement fall from stack in random directions
		target.y = rng.randf_range(-10000.0, 10000.0)

	if foot_friend:
		$Body.play("idleative")
		target = offset_to(foot_friend) + Vector2.UP * 70
	else:
		target.x = Input.get_axis("go left","go right") * 200
		# Add the gravity.
		if not is_on_floor():
			target += get_gravity() * delta * 100

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
	if get_direction(offset_to(detected_gaura)) == Direction.DOWN && disarray == false:
		var detected_gourt = detected_gaura.get_parent()
		if !foot_friend: foot_friend = detected_gourt
		print(gourt_name + " feet friended " + detected_gourt.gourt_name)

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
