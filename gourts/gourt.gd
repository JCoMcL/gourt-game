class_name Gourt
extends Actor #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)


@export var head_friend: CharacterBody2D
@export var foot_friend: CharacterBody2D

@export var snap_distance = 120
@export var stack_elasticity = 0.5 #FIXME: setting this above 0.5 results in infinte-energy.

@onready var BODY: AnimatedSprite2D = $Body
@onready var FACE: AnimatedSprite2D = $Body/Face

var angular_velocity: float = 0

func identify(lines = []):
	super([
		"My Head Friend: %s" % head_friend.name if head_friend else "",
		"My Foot Friend: %s" % foot_friend.name if foot_friend else "",
		"Am at {0} local, {1} global".format([position, global_position]),
		"I would like to be at %s" % Gourtilities.global_perch_position(foot_friend) if foot_friend else "",
		"My velocity: %.2v" % velocity
	] + lines)

func break_stack(impulse_scale: int = 1) -> void:
	if foot_friend:
		foot_friend.head_friend = null
		foot_friend = null
	apply_force(Vector2(
		Yute.triangular_distribution(-2, 2),
		Yute.triangular_distribution(-1, -2)
	) * impulse_scale, "breaksplosion")

#TODO reimplement to be less guesswork-oriented 
func get_global_rect() -> Rect2:
	if head_friend:
		return head_friend.get_global_rect()
	else:
		var self_bounds = super()
		self_bounds.size.y *= Gourtilities.foot_count(self)
		return self_bounds

func abdicate(nominee: Actor = null) -> bool:
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
	super()
	abdicate()
	if head_friend:
		head_friend.velocity.y = -200
		head_friend.velocity.x *= 0.6

	if foot_friend:
		foot_friend.head_friend = null #BM1
		foot_friend = null
	if head_friend:
		head_friend.foot_friend = null
		head_friend = null

	# Animation
	auto_animate = false
	face_anim="A_lifeless"
	body_anim=fall_anim
	FACE.play(face_anim)
	FACE.set_frame_and_progress(
		int( (Yute.randf_exp()) * FACE.sprite_frames.get_frame_count(face_anim) ),
		0
	)
	FACE.visible = false # Face will be made visible by main animation loop after shock animation ends
	BODY.play(get_animations_of_type(BODY, "A_explosive").pick_random())
	angular_velocity += Yute.triangular_distribution(-5,5)

	$DeathSFX.play()

func command(c: Commands) -> void:
	if foot_friend:
		foot_friend.command(c)
		walk_target = 0
	else:
		super(c)

func scan_for_perch(distance: float = snap_distance): #FIXME, this only finds one match, so fails with overlapping gourts. Perhaps intersect_point would be better?
	var result = get_world_2d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + Vector2.DOWN * distance)
	)
	if result and result.collider is Gourt and not result.collider.head_friend: #BM1
		identify(["just stacked to %s" % result.collider.name])
		Gourtilities.stack(self, result.collider)

func interact(operator: Node) -> bool:
	var o = get_equipped_item()
	if o:
		return o.interact(operator)
	return false

func perform_the_interaction_fr(what: Node, where: Vector2) -> bool:
	var d = Direction.get_relative(self, where)
	auto_animate = false
	BODY.play("A_probative_%s" % Direction.pretty(d))
	set_facing(d)

	if what is Gourt: #baby, don't hurt me
		# render ontop of target gourt to make poking animations look better
		# this will get reset automatically in the main animation loop
		z_index = max(z_index, what.z_index+1)

	var items_to_use = Gourtilities.get_items_useable_for_interaction(self, what)
	for item in items_to_use:
		var did_it_work = what.interact(item)
		if did_it_work:
			return true

	return what.interact(self)

func _interact(what: Node, where: Vector2) -> bool:
	var gourt: Gourt
	if what is Word:
		gourt = Gourtilities.get_stack_tip(self)
		gourt.say(what.examine(gourt))
		return true
	elif what.has_method("interact"):
		gourt = get_closest_gourt_to_interact(what, where)
		if gourt:
			if what is Word:
				gourt.say(what.examine(gourt))
				return true
			return gourt.perform_the_interaction_fr(what, where)
	return false

func sqr_dist_to(o) -> float:
	if o is Vector2:
		return global_position.distance_squared_to(o)
	elif o is Node2D:
		return sqr_dist_to(o.global_position)
	assert(false, "Type Error: {0}".format([o]))
	return INF

func am_closest_to(o) -> bool:
	var d = sqr_dist_to(o)
	return (
		((not head_friend) or (head_friend.sqr_dist_to(o) > d)) and
		((not foot_friend) or (foot_friend.sqr_dist_to(o) > d))
	)

func can_reach(o) -> bool: #TODO more reliable test would check if we can reach any part, not just the center
	if o is Word:
		return true
	return sqr_dist_to(o) < reach ** 2

func get_closest_gourt_to_interact(what: Node2D, where: Vector2) -> Gourt:
	var gourts_in_reach = Gourtilities.list_stack_members(self).filter(func(g): return (
		(g.can_reach(where) or g.can_reach(what)) and
		g != what and
		g != Gourtilities.get_equipment_owner(what)
	))
	return gourts_in_reach.reduce(func(closest, g):
		return g if g.sqr_dist_to(where) < closest.sqr_dist_to(where) else closest
	)

func get_equipped_item() -> Equippable:
	for slot in [
		$Body/HandSlot1,
		$Body/HandSlot2,
		$Body/Face/EyesSlot
	]:
		if slot.get_child_count() > 0:
			return slot.get_child(0)
	return null


func move_equipment(direction: int, equipment: Node = null) -> Node:
	if not equipment:
		equipment = get_equipped_item()
	if not equipment:
		return
	match direction:
		Direction.UP:
			if head_friend:
				equipment.interact(head_friend)
		Direction.DOWN:
			if foot_friend:
				equipment.interact(foot_friend)
	return equipment

func apply_force_recursive_upwards(force: Vector2, factor=1.0, label=""):
	force *= factor
	apply_force(force, label)
	if head_friend:
		head_friend.apply_force_recursive_upwards(force, factor, label)

func collide_with_rigidbody(k: KinematicCollision2D, restitution=0.2, force_ratio=10):
	var our_mass = mass * Gourtilities.stack_count(self)
	var their_mass = k.get_collider().mass

	var relative_velocity_along_normal = (
		velocity_before_move - k.get_collider_velocity()
	).dot( k.get_normal())

	if relative_velocity_along_normal > 0:
		return

	var f = (1+restitution) * relative_velocity_along_normal / (1.0/our_mass + 1.0/their_mass) * k.get_normal()

	k.get_collider().apply_force(f * force_ratio, k.get_position() - k.get_collider().global_position )
	apply_force(-f / Gourtilities.stack_count(self), "rigid reaction" )

func handle_collision(k: KinematicCollision2D):
	super(k)
	if k.get_collider() is RigidBody2D:
		collide_with_rigidbody(k)

func _physics_process(delta: float) -> void:
	if foot_friend:
		var target_offset = Gourtilities.global_perch_position(foot_friend) - global_position
		var f = Yute.snap_force(velocity, target_offset, delta) * mass;
		if target_offset.length() > snap_distance:
			foot_friend.apply_force(f, "snapback")
			break_stack()
			apply_force_recursive_upwards(-f, 1.0, "rebound")
		else:
			apply_force(f, "snap")
			foot_friend.apply_force(-f * stack_elasticity, "elastic")

	elif velocity.y > 0:
		scan_for_perch()

	super(delta) #performs move_and_slide
	if is_on_floor():
		angular_velocity = 0

# TODO a lot of this code should be moved into the AnimatedSprite2D
const IDLE = "I_"
const ACTIVE = "A_"
func get_animations_of_type(body_part: AnimatedSprite2D, prefix: String):
	var out = []
	for s in body_part.sprite_frames.get_animation_names():
		if s.begins_with(prefix):
			out.append(s)
	return out

var body_anim: String
var face_anim: String
var fall_anim: String
func _ready():
	body_anim = get_animations_of_type(BODY, IDLE).pick_random()
	face_anim = get_animations_of_type(FACE, IDLE).pick_random()
	fall_anim = get_animations_of_type(BODY, "A_restive").pick_random()
	BODY.animation_finished.connect(resume_auto_animate)

var auto_animate = true
func resume_auto_animate():
	auto_animate = true

func animate(delta: float):
	BODY.visible = true
	FACE.visible = true
	z_index = Gourtilities.foot_count(self) + 1 #render gourts ontop of foot friends

	if foot_friend and abs(velocity.x) > 100 and Yute.percent_chance(abs(velocity.x) / 50):
		set_facing(foot_friend.facing)

	if velocity.y > 100: #falling
		angular_velocity += 1 * delta * sign(-velocity.x if angular_velocity == 0 else angular_velocity)
		if Yute.percent_chance(velocity.y / 100):
			BODY.play(fall_anim)
	elif walk_target != 0:
		BODY.play("A_transportative")
		set_facing(Direction.get_x(walk_target))
	else:
		BODY.play(body_anim)
		FACE.play(face_anim)

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

	# Animation
	auto_animate = false
	face_anim="A_lifeless"
	body_anim=fall_anim
	FACE.play(face_anim)
	FACE.set_frame_and_progress(
		int( (Yute.randf_exp()) * FACE.sprite_frames.get_frame_count(face_anim) ),
		0
	)
	FACE.visible = false # Face will be made visible by main animation loop after shock animation ends
	BODY.play(get_animations_of_type(BODY, "A_explosive").pick_random())
	angular_velocity += Yute.triangular_distribution(-5,5)

	$DeathSFX.play()

func _process(delta: float) -> void:
	if foot_friend or head_friend or is_on_floor():
		BODY.rotation = 0
	else:
		BODY.rotation += angular_velocity * delta

	if auto_animate:
		animate(delta)

func _input(ev: InputEvent) -> void:
	super(ev)
	if ev.is_action_pressed("enter door"):
		Gourtilities.call_all(self, func(g): g.try_enter_door())
