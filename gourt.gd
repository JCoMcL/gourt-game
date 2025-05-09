class_name Gourt
extends Goon #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)

enum Direction {UP, DOWN, LEFT, RIGHT, NONE}
@export var facing = Direction.LEFT

@export var head_friend: CharacterBody2D
@export var foot_friend: CharacterBody2D

@export var debug_mode = false
func debug_print(s):
	if debug_mode: print(s)

var rng = RandomNumberGenerator.new()
func triangular_distribution(lower: float = -1.0, upper: float = 1.0) -> float:
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

func identify(lines = []):
	super([
		"My Head Friend: %s" % head_friend.name if head_friend else "",
		"My Foot Friend: %s" % foot_friend.name if foot_friend else "",
		"Am at {0} local, {1} global".format([position, global_position]),
		"I would like to be at %s" % Gourtilities.global_perch_position(foot_friend) if foot_friend else ""
	])

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

func gaura_detect(detected_gaura: Node2D):
	if get_direction(offset_to(detected_gaura)) == Direction.DOWN && !foot_friend:
		Gourtilities.stack(self, detected_gaura.get_parent())

func break_stack(impulse_scale: int = 1) -> void:
	if foot_friend:
		foot_friend.head_friend = null
		foot_friend = null
	velocity += Vector2(
		triangular_distribution(-2, 2),
		triangular_distribution(-1, -2)
	) * impulse_scale

func snap_to_global(target:Vector2, delta:float, snappiness:float = 600, sharpness:float = 0.3):
	velocity = velocity.move_toward((target - global_position) * sharpness / delta, snappiness)

func snap_to(target:Vector2, delta:float, snappiness:float = 600, sharpness:float = 0.3):
	velocity = velocity.move_toward((target - position) * sharpness / delta, snappiness)

# far from perfect but works well enough for now
func get_bounds() -> Rect2:
	if head_friend:
		return head_friend.get_bounds()
	else:
		var self_bounds = super()
		self_bounds.size.y *= Gourtilities.foot_count(self)
		return self_bounds

func abdicate() -> bool:
	if not master:
		return false #idk whether it should be true or false, we'll have to see
	if foot_friend and master.nominate(foot_friend):
		return true
	if head_friend and master.nominate(head_friend):
		return true
	return master.nominate(null)

func die():
	collision_layer = 0
	collision_mask = 0
	walk_target = 0
	abdicate()
	if foot_friend:
		foot_friend.head_friend = null #BM1
		foot_friend = null
	if head_friend:
		head_friend.foot_friend = null
		head_friend = null


func yeetonate():
	velocity = Vector2(triangular_distribution() * 320, triangular_distribution(-2,-3) * 20)
	if head_friend:
		head_friend.velocity.y = -200
		head_friend.velocity.x *= 0.6
	die()

func _input(ev: InputEvent) -> void:
	if ev.is_action_pressed("break stack") && foot_friend:
		break_stack(200)

var walk_target: float
func command(c: Commands) -> void:
	if foot_friend:
		foot_friend.command(c)
	else:
		walk_target = c.walk * 200

func _process(delta: float) -> void:
	set_facing(x_direction( velocity.x if foot_friend else walk_target ))
	if walk_target != 0:
		$Body.play("transportative")
	else:
		$Body.play("idleative")

#var special_layer = ProjectSettings.get_setting("layer_names/2d_physics/special solid")
const special_layer = 4
func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer( k.get_collider_rid() ) & special_layer

func check_collision():
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if is_special_collision(col):
			yeetonate()

func _physics_process(delta: float) -> void:
	if !is_on_floor() && !foot_friend:
		velocity += get_gravity() * delta

	if foot_friend:
		snap_to_global(Gourtilities.global_perch_position(foot_friend), delta)
		walk_target = 0

	if walk_target != 0 || is_on_floor(): #this check prevents unwanted drag on airborne guorts
		velocity.x = move_toward(velocity.x, walk_target, 20)

	move_and_slide()
	check_collision()

func _ready() -> void:
	$Gaura.area_entered.connect(gaura_detect)
