class_name Gourt
extends Goon #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)

@export var facing = Direction.LEFT

@export var head_friend: CharacterBody2D
@export var foot_friend: CharacterBody2D

@export_category("motion")
@export var walk_speed = 200
@export var walk_accel = 20
@export var walk_friction = 0.6 #this could be a puzzle mechanic
@export var snap_distance = 120
@export var stack_elasticity = 0.8 #FIXME: setting this above 0.5 results in infinte-energy.
@export var mass = 20
@export var reach = 180

var selected_equipment = null
var rng = RandomNumberGenerator.new()
func triangular_distribution(lower: float = -1.0, upper: float = 1.0) -> float:
	return rng.randf_range(upper, lower) + rng.randf_range(upper, lower)

func identify(lines = []):
	super([
		"My Head Friend: %s" % head_friend.name if head_friend else "",
		"My Foot Friend: %s" % foot_friend.name if foot_friend else "",
		"Am at {0} local, {1} global".format([position, global_position]),
		"I would like to be at %s" % Gourtilities.global_perch_position(foot_friend) if foot_friend else "",
		"My velocity: %.2v" % velocity,
		"Forces last physics tick:\n%s" % saved_forces.map(func(f): return f._string()).reduce(func(acc, s): return "%s\n%s" % [acc, s]) if saved_forces else ""
	] + lines)

func flip() -> void:
	transform.x *= -1

func set_facing(d: int) -> void:
	if d == Direction.NONE:
		return
	assert(d == Direction.LEFT || d == Direction.RIGHT)
	if d != facing:
		flip()
		facing = d

func break_stack(impulse_scale: int = 1) -> void:
	if foot_friend:
		foot_friend.head_friend = null
		foot_friend = null
	apply_force(Vector2(
		triangular_distribution(-2, 2),
		triangular_distribution(-1, -2)
	) * impulse_scale, "breaksplosion")

func snap_force(initial:Vector2, direction:Vector2, delta:float, snappiness:float = 300, sharpness:float = 0.3) -> Vector2:
	return initial.move_toward(direction * sharpness / (delta / Engine.time_scale), snappiness) - initial #TODO refactor

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
		walk_target = 0
	else:
		walk_target = c.walk * walk_speed

func scan_for_perch(distance: float = snap_distance): #FIXME, this only finds one match, so fails with overlapping gourts. Perhaps intersect_point would be better?
	var result = get_world_2d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + Vector2.DOWN * distance)
	)
	if result and result.collider is Gourt and not result.collider.head_friend: #BM1
		identify(["just stacked to %s" % result.collider.name])
		Gourtilities.stack(self, result.collider)

func try_enter_door():
	var result = Clision.get_objects_at(global_position, "door")
	if result.size() == 0:
		return

	result[0].interract(self)

func interract(interractable):
	var gourt = get_closest_gourt_to_interact(interractable)
	if gourt:
		interractable.interract(gourt)

func sqr_dist_to(o: Node2D):
	return global_position.distance_squared_to(o.global_position)

func can_reach(o: Node2D):
	return sqr_dist_to(o) < reach ** 2

func get_closest_gourt_to_interact(interactable: Node2D) -> Gourt:
	var gourts_in_reach = Gourtilities.list_stack_members(self).filter(func(g): return g.can_reach(interactable))
	return gourts_in_reach.reduce(func(g, closest):
		return g if sqr_dist_to(interactable) < closest.sqr_dist_to(interactable) else closest
	)

func select_equipment(equipment):
	selected_equipment = equipment

func move_equipment_up():
	var gourt = Gourtilities.get_equipment_owner(selected_equipment)
	if gourt and gourt.head_friend:
		selected_equipment.interract(gourt.head_friend)

func move_equipment_down():
	var gourt = Gourtilities.get_equipment_owner(selected_equipment)
	if gourt and gourt.foot_friend:
		selected_equipment.interract(gourt.foot_friend)

func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer( k.get_collider_rid() ) & Clision.layers["special solid"]

class Force:
	var value: Vector2
	var name: String
	func _init(f, s=""):
		value=f
		name= s if s else "unknown"

	func _string():
		return "%s: %.2v" % [name, value]

var forces = []
var saved_forces=forces
func apply_force(force: Vector2, label=""):
	forces.append(Force.new(force, label))

func apply_force_recursive_upwards(force: Vector2, factor=1.0, label=""):
	force *= factor
	apply_force(force, label)
	if head_friend:
		head_friend.apply_force_recursive_upwards(force, factor, label)

func apply_friction(factor: Vector2, label="friction"): #FIXME I think this isn't phyiscally accurate
	var friction = Vector2.ZERO
	for f in forces:
		friction += f.value * -factor
	apply_force(friction, label)

func collide_with_rigidbody(k: KinematicCollision2D, delta, restitution=0.2, force_ratio=20):
	var our_mass = mass * Gourtilities.stack_count(self)
	var their_mass = k.get_collider().mass

	var relative_velocity_along_normal = (
		velocity_before_move - k.get_collider_velocity()
	).dot( k.get_normal())

	if relative_velocity_along_normal > 0:
		return

	var f = (1+restitution) * relative_velocity_along_normal / (1.0/our_mass + 1.0/their_mass) * k.get_normal()

	k.get_collider().apply_force(f * force_ratio, k.get_position() - k.get_collider().global_position )
	apply_force(-f * delta / Gourtilities.stack_count(self), "rigid reaction" )

var velocity_before_move: Vector2
func _physics_process(delta: float) -> void:
	apply_force(get_gravity() * delta * mass, "gravity")

	if foot_friend:
		var target_offset = Gourtilities.global_perch_position(foot_friend) - global_position
		var f = snap_force(velocity, target_offset, delta) * mass;
		if target_offset.length() > snap_distance:
			foot_friend.apply_force(f, "snapback")
			break_stack()
			apply_force_recursive_upwards(-f, 1.0, "rebound")
		else:
			apply_force(f, "snap")
			foot_friend.apply_force(-f * stack_elasticity, "elastic")

	elif velocity.y > 0:
		scan_for_perch()


	if is_on_floor():
		apply_friction(Vector2(walk_friction,0))

	if walk_target != 0 || is_on_floor(): #this check prevents unwanted drag on airborne guorts
		velocity.x = move_toward(velocity.x, walk_target, walk_accel)

	for f in forces:
		velocity += f.value / mass
	saved_forces=forces
	forces = []

	velocity_before_move = velocity
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var k = get_slide_collision(i)
		if is_special_collision(k):
			yeetonate()
		if k.get_collider() is RigidBody2D:
			collide_with_rigidbody(k, delta)

func _process(delta: float) -> void:
	set_facing(Direction.get_x( velocity.x if foot_friend else walk_target, 10))
	if walk_target != 0:
		$Body.play("transportative")
	else:
		$Body.play("idleative")

func _input(ev: InputEvent) -> void:
	if ev.is_action_pressed("enter door"):
		Gourtilities.call_all(self, func(g): g.try_enter_door())
