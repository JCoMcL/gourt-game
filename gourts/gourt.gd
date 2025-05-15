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
	return Direction.UP if y > 0 else Direction.DOWN #WARN untested
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
	] + lines)

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

func break_stack(impulse_scale: int = 1) -> void:
	if foot_friend:
		foot_friend.head_friend = null
		foot_friend = null
	velocity += Vector2(
		triangular_distribution(-2, 2),
		triangular_distribution(-1, -2)
	) * impulse_scale

func snap_to_global(target:Vector2, delta:float, snappiness:float = 600, sharpness:float = 0.3):
	snap_towards((target - global_position), delta, snappiness, sharpness)

func snap_to(target:Vector2, delta:float, snappiness:float = 600, sharpness:float = 0.3):
	snap_towards((target - position), delta, snappiness, sharpness)

func snap_towards(direction:Vector2, delta:float, snappiness:float = 600, sharpness:float = 0.3):
	velocity = velocity.move_toward(direction * sharpness / delta, snappiness)

#TODO reimplement to be less guesswork-oriented 
func get_bounds() -> Rect2:
	if head_friend:
		return head_friend.get_bounds()
	else:
		var self_bounds = super()
		self_bounds.size.y *= Gourtilities.foot_count(self)
		return self_bounds

func abdicate(nominee: Goon = null) -> bool:
	if not master:
		return false #idk whether it should be true or false, we'll have to see
	if nominee:
		return master.nominate(nominee)
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

func scan_for_perch(distance: float = 120):
	var result = get_world_2d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + Vector2.DOWN * distance)
	)
	if result and result.collider is Gourt:
		Gourtilities.stack(self, result.collider)

#var special_layer = ProjectSettings.get_setting("layer_names/2d_physics/special solid")
const special_layer = 4
func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer( k.get_collider_rid() ) & special_layer

func check_collision():
	for i in range(get_slide_collision_count()):
		var k = get_slide_collision(i)
		if is_special_collision(k):
			yeetonate()
		if k.get_collider() is RigidBody2D:
			k.get_collider().apply_force(k.get_remainder() * 100, k.get_position())
		if foot_friend:
			foot_friend.apply_force(k.get_remainder() * -20)

var forces = []
func apply_force(force: Vector2):
	identify(["%v" % force])
	forces.append(force)

func _physics_process(delta: float) -> void:
	if !is_on_floor() && !foot_friend:
		velocity += get_gravity() * delta

	if foot_friend:
		var target_offset = Gourtilities.global_perch_position(foot_friend) - global_position
		if target_offset.length() > (60):
			break_stack()
		else:
			snap_towards(target_offset, delta / Engine.time_scale)
	else:
		scan_for_perch()

	if walk_target != 0 || is_on_floor(): #this check prevents unwanted drag on airborne guorts
		velocity.x = move_toward(velocity.x, walk_target, 20)

	for f in forces:
		velocity += f
	forces = []

	move_and_slide()
	check_collision()
