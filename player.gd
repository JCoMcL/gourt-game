extends Camera2D
class_name Master #TODO: this class should be more generic: player and AI should inheret from it

@export var player_character: Goon:
	set(g):
		if valid_goon(player_character):
			player_character.under_new_management(null)
		if valid_goon(g):
			g.under_new_management(self)
		player_character = g

@export_range(1, 100) var position_smoothing: float = 10
@export_range(0, 100) var position_threshold: float = 10
@export_range(1, 1000) var zoom_smoothing: float = 100
@export_range(1, 10) var max_zoom: float = 1

func valid_goon(g: Goon) -> bool:
	return g and is_instance_valid(g)

func _ready():
	#move to bottom of tree to recieve inputs first among siblings.
	#TODO how does input priority work exactly? Does it make this reording unneccesary?
	get_parent().move_child.call_deferred(self, -1)
	if valid_goon(player_character):
		player_character.under_new_management(self)
	else:
		player_character = Goon.new() #easier than constant null-checking

func get_commands(c: Goon.Commands = null) -> Goon.Commands:
	if not c:
		c = Goon.Commands.new()
	c.walk = Input.get_axis("go left","go right")
	return c

func _process(delta):
	Engine.time_scale = 0.1 if Input.is_action_pressed("slomo") else 1.0

	if player_character:
		player_character.command(get_commands())
		var track_bounds = player_character.get_global_rect()
		var view_bounds = Yute.get_viewport_world_rect(self)
		var error_vectors = [
			track_bounds.position - view_bounds.position,
			track_bounds.end - view_bounds.end
		]
		var position_error = (error_vectors[0] + error_vectors[1]) / 2
		var zoom_error = min(
			(error_vectors[0].x - error_vectors[1].x) / view_bounds.size.x,
			(error_vectors[0].y - error_vectors[1].y) / view_bounds.size.y
		) #TODO: this is not 100% correct, you can still see substantuially more with a bigger screen
		# the goal is to completely abstract out screen size so we never have to worry about it again
		global_position += position_error.move_toward(Vector2.ZERO, position_threshold) / position_smoothing
		zoom = lerp(zoom, Vector2.ONE * zoom_error, 1/zoom_smoothing)

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
	#don't consume probe events, let the goon handle them directly
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
	elif valid_goon(player_character):
		player_character._input(ev)

func game_over():
	print("Goodbye World!") #TODO actual game-over

func nominate(g: Goon) -> bool:
	if not g:
		game_over()
		player_character = null
		return false
	player_character = g
	return player_character == g
