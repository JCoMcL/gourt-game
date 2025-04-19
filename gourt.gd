class_name Gourt
extends Goon #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)

enum Direction {UP, DOWN, LEFT, RIGHT, NONE}
@export var facing = Direction.LEFT

@export var head_friend: CharacterBody2D
@export var foot_friend: CharacterBody2D

@export var disarray = false #Defines if gourts can be assembled in gourtstack

@export var debug_mode = false
func debug_print(s):
	if debug_mode: print(s)

var rng = RandomNumberGenerator.new()
func triangular_distribution(lower: float, upper: float) -> float:
	return rng.randf_range(upper, lower) + rng.randf_range(upper, lower)

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
	return Direction.NONE

func pretty_direction(i:int):
	return Direction.keys()[i]

func x_direction(x: float):
	if absf(x) < 10: return Direction.NONE
	return Direction.RIGHT if x > 0 else Direction.LEFT
func y_direction(y: float):
	if absf(y) < 10: return Direction.NONE
	return Direction.UP if y > 0 else Direction.DOWN #WARN: untested
func vec_direction(v: Vector2):
	if absf(v.x) > absf(v.y):
		return x_direction(v.x)
	return y_direction(v.y)

func flip() -> void:
	transform.x *= -1

func set_facing(d: Direction) -> void:
	if d == Direction.NONE:
		return
	assert(d == Direction.LEFT || d == Direction.RIGHT)
	if d != facing:
		flip()
		facing = d

func offset_to(body: Node2D) -> Vector2:
	return body.global_position - global_position

func stack_onto(o: Gourt):
	foot_friend = o
	o.head_friend = self

func gaura_detect(detected_gaura: Node2D):
	if get_direction(offset_to(detected_gaura)) == Direction.DOWN && !disarray && !foot_friend:
		Gourtilities.stack(self, detected_gaura.get_parent())

func break_stack(impulse_scale: int = 1) -> void:
	disarray = true
	foot_friend = null
	velocity += Vector2(
		triangular_distribution(-2, 2),
		triangular_distribution(-1, -2)
	) * impulse_scale

func snap_to(target:Vector2, delta:float, snappiness:float = 600, sharpness:float = 0.3):
	velocity = velocity.move_toward((target - position) * sharpness / delta, snappiness)

func get_move_command() -> float:
	if foot_friend:
		foot_friend.commands = commands #FIXME: overwriting commands is not smart
	return commands.walk

func command(ev: InputEvent) -> void:
	if ev.is_action_pressed("break stack") && foot_friend:
		break_stack(200)

var walk_target: float

func _process(delta: float) -> void:
	set_facing(x_direction( velocity.x if foot_friend else walk_target ))
	if walk_target != 0:
		$Body.play("transportative")
	else:
		$Body.play("idleative")

func _physics_process(delta: float) -> void:
	walk_target = get_move_command() * 200

	if !is_on_floor() && !foot_friend:
		velocity += get_gravity() * delta

	if foot_friend:
		snap_to(Gourtilities.perch_position(foot_friend), delta)
		walk_target = 0

	if walk_target != 0 || is_on_floor(): #this check prevents unwanted drag on airborne guorts
		velocity.x = move_toward(velocity.x, walk_target, 20)

	move_and_slide()

func _ready() -> void:
	$Gaura.area_entered.connect(gaura_detect)
