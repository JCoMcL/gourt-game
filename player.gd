extends Camera2D
class_name Master #TODO: this class should be more generic: player and AI should inheret from it

@export var player_character: Actor:
	set(a):
		if valid_actor(player_character):
			player_character.under_new_management(null)
		if valid_actor(a):
			a.under_new_management(self)
		player_character = a

@export_range(0, 1) var position_smoothing: float = 0.1
@export_range(0, 500) var position_threshold: float = 50
@export_range(0, 5) var zoom_smoothing: float = 1
@export_range(1, 10) var max_zoom: float = 1

func valid_actor(a: Actor) -> bool:
	return a and is_instance_valid(a) and a is Actor

func _ready():
	#move to bottom of tree to recieve inputs first among siblings.
	#TODO how does input priority work exactly? Does it make this reording unneccesary?
	get_parent().move_child.call_deferred(self, -1)
	if valid_actor(player_character):
		player_character.under_new_management(self)
	else:
		player_character = Actor.new() #easier than constant null-checking

func get_commands(c: Actor.Commands = null) -> Actor.Commands:
	if not c:
		c = Actor.Commands.new()
	c.walk = Input.get_axis("go left","go right")
	return c

func _process(delta):
	if player_character:
		player_character.command(get_commands())
	Engine.time_scale = 0.1 if Input.is_action_pressed("slomo") else 1.0

class TrackingError:
	var position_error: Vector2
	var zoom_error: float
	func _init(position_error: Vector2, zoom_error: float):
		self.position_error = position_error
		self.zoom_error = zoom_error

func get_tracking_error(track_bounds: Rect2, track_target: Rect2) -> TrackingError:
	var error_vectors = [
		track_target.position - track_bounds.position,
		track_target.end - track_bounds.end
	]
	return TrackingError.new(
		(error_vectors[0] + error_vectors[1]) / 2,
		min(
			(error_vectors[0].x - error_vectors[1].x) / track_bounds.size.x,
			(error_vectors[0].y - error_vectors[1].y) / track_bounds.size.y
		)
	)

func smooth(delta: float, smoothing: float):
	return (delta / smoothing) if smoothing > 0 else 1

func _physics_process(delta: float) -> void:
	if player_character:
		var track_rects: Array[Rect2]
		if player_character is Gourt:
			for g in Gourtilities.list_stack_members(player_character):
				track_rects.append(Yute.get_global_rect(g))
		else:
			track_rects = [Yute.get_global_rect(player_character)]
		var primary_track_rect = Yute.union_rect(track_rects)
		$ActivationZone.global_position = primary_track_rect.get_center()
		$ActivationZone.encompass(primary_track_rect)

		for a: Area2D in $ActivationZone.get_overlapping_areas():
			track_rects.append(Yute.get_global_rect(a))

		var t_err = get_tracking_error(
			Yute.get_viewport_world_rect(self),
			Yute.union_rect(track_rects),
		)
		# TODO additional zones should have different smoothing settings than the player:
		global_position += t_err.position_error.move_toward(Vector2.ZERO, position_threshold) * smooth(delta, position_smoothing)
		zoom = lerp(zoom, Vector2.ONE * t_err.zoom_error, smooth(delta, zoom_smoothing))

func event_position(ev: InputEvent) -> Vector2:
	if ev is InputEventMouse or ev is InputEventScreenTouch:
		return Yute.viewport_to_world(ev.position, player_character)
	# idk what to do here, we'll have to see
	if "position" in ev:
		return player_character.global_position + ev.position
	return player_character.global_position

var _selected_gourt: Gourt
var _selected_item: Node
func invalidate_selection():
	_selected_item = null
	_selected_gourt = null

func quick_move_item(item: Node, direction: int):
	if item is Gourt:
		if _selected_item and item == _selected_gourt:
			_selected_item = Gourtilities.get_equipment_owner(_selected_item).move_equipment(direction, _selected_item)
		else:
			_selected_gourt = item
			_selected_item = item.move_equipment(direction)
	else:
		_selected_gourt = Gourtilities.get_equipment_owner(item)
		if _selected_gourt:
			_selected_item = _selected_gourt.move_equipment(direction, item)

func try_quick_move_item(ev: InputEvent, direction: int):
	var items = Clision.get_objects_at(event_position(ev), "interactive") #TODO sort this list for more consisten results
	if _selected_gourt not in items:
		_selected_gourt = null

	if items:
		var item_gourt = items[0] if items[0] is Gourt else Gourtilities.get_equipment_owner(items[0])
		if Gourtilities.in_same_stack(player_character, item_gourt):
			quick_move_item(items[0], direction)
			return
	if _selected_item:
		if Gourtilities.in_same_stack(player_character, Gourtilities.get_equipment_owner(_selected_item)):
			quick_move_item(_selected_item, direction)
		else:
			_selected_item = null


func _input(ev: InputEvent):
	#don't consume probe events, let the actor handle them directly
	if not ev.is_action_pressed("probe"):
		get_viewport().set_input_as_handled()

	if ev.is_action_pressed("interact"):
		var ev_pos = event_position(ev)
		var interactables = Clision.get_objects_at(ev_pos, "interactive")
		if interactables:
			player_character._interact(interactables[0], ev_pos) #TODO we should try to handle the whole array not just whatever is arbitrarily the first element
	elif ev.is_action_pressed("move equipment up"):
		try_quick_move_item(ev, Direction.UP)
	elif ev.is_action_pressed("move equipment down"):
		try_quick_move_item(ev, Direction.DOWN)
	elif valid_actor(player_character):
		player_character._input(ev)

func game_over():
	await get_tree().create_timer(1).timeout
	Yute.get_level_container(self).reset_level()

func nominate(a: Actor) -> bool:
	if not a:
		game_over()
		player_character = null
		return false
	player_character = a
	return player_character == a
