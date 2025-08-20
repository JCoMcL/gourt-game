class_name Actor
extends CharacterBody2D #TODO: I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)

@export var facing = Direction.LEFT
@export var reach = 180

@export_category("physics")
@export var walk_speed = 200
@export var walk_accel = 20
@export var mass = 20
@export var walk_friction = 0.6 #this could be a puzzle mechanic

var walk_target: float: # where we walkin' as a proportion of our speed
	set(f):
		walk_target = clampf(f, -1, 1)
var target
var social_distance = 20.0
var active_command: Commands = null

# --- Bounds ---

var bounds_size = 60 #TODO this is the gourt's size, and it's a guess

func get_rect() -> Rect2:
	## a Rect2 representing the boundary of the goon in local coordinates
	var r = get_global_rect()
	r.position -= global_position
	return r

func get_global_rect() -> Rect2:
	return Rect2(
		global_position - Vector2.ONE * bounds_size,
		Vector2.ONE * bounds_size * 2
	)

func get_mouth():
	return get_node_or_null("Sprite2D/Handle/Speak Hole")

# --- Direction ---

func flip() -> void:
	transform.x *= -1

func set_facing(d: int) -> void:
	if (d == Direction.LEFT or d == Direction.RIGHT) and d != facing:
		flip()
		facing = d

# --- Actions ---

func die():
	target = null
	velocity.x += Yute.triangular_distribution() * 120
	velocity.y = Yute.triangular_distribution(-2,-3) * 40
	collision_layer = 0
	collision_mask = 0
	walk_target = 0

func say(s: String):
	SpeechTherapist.say(self, s)

func identify(lines = []):
	for s in [
		"\nI am %s" % name
	] + lines:
		if s:
			print(s)

func try_enter_door():
	var result = Clision.get_objects_at(global_position, "door")
	if result.size() == 0:
		return

	result[0].interact(self)

func move_to_target():
	var dx = target.x - global_position.x
	if abs(dx) < social_distance:
		target = null
		return

	walk_target = dx

func exit_stage_left():
	target = Vector2(-INF, 0)
func exit_stage_right():
	target = Vector2(INF, 0)

# --- Inter Actions

func _interact(what: Node, where: Vector2) -> bool:
	if what.has_method("interact"):
		return what.interact(self)
	return false

# --- Commands ---

class Commands: # Structure containing what to do each frame
	var walk: float

func _input(ev: InputEvent): # This is currently needed for interface compliance, but might be expanded to actually do something
	pass

func _input_event(viewport: Node, ev: InputEvent, shape_idx: int):
	if ev.is_action_pressed("probe"):
		identify()

func command(c: Commands) -> void:
	walk_target = c.walk
	if walk_target != 0:
		target = null #TODO this this pretty naive since commands are issued every frame

var master: Master
func under_new_management(m: Master):
	master = m

# --- Faux Physics ---

class Force:
	var value: Vector2
	var name: String
	func _init(f, s=""):
		value=f
		name= s if s else "unknown"

	func _string():
		return "%s: %.2v" % [name, value]

var forces = []
func apply_force(force: Vector2, label=""):
	forces.append(Force.new(force, label))

func apply_friction(factor: Vector2, label="friction"): #FIXME I think this isn't physically accurate
	var friction = Vector2.ZERO
	for f in forces:
		friction += f.value * -factor
	apply_force(friction, label)

func is_special_collision(k: KinematicCollision2D) -> bool:
	return PhysicsServer2D.body_get_collision_layer( k.get_collider_rid() ) & Clision.layers["special solid"]

func handle_collision(k: KinematicCollision2D):
	if is_special_collision(k):
		die()

var velocity_before_move: Vector2
func _physics_process(delta: float) -> void:
	apply_force(get_gravity() * delta * mass, "gravity")

	if is_on_floor():
		apply_friction(Vector2(walk_friction,0))

	if walk_target != 0 || is_on_floor(): #this check prevents unwanted drag on airborne guorts
		velocity.x = move_toward(velocity.x, walk_target * walk_speed, walk_accel)

	if target:
		move_to_target()

	for f in forces:
		velocity += f.value / mass
	forces = []

	velocity_before_move = velocity
	move_and_slide()
	for i in range(get_slide_collision_count()):
		handle_collision(get_slide_collision(i))

# --- Apearance ---

func _process(delta):
	set_facing(Direction.get_x(walk_target))
