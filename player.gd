extends Camera2D
class_name Master #TODO: this class should be more generic: player and AI should inheret from it

@export var player_character: Goon:
	set(g):
		if valid_goon(player_character):
			player_character.under_new_management(null)
		if valid_goon(g):
			g.under_new_management(self)
		player_character = g

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
	var track_bounds = player_character.get_bounds()
	offset = (track_bounds.get_center() - player_character.global_position)

func get_commands(c: Goon.Commands = null) -> Goon.Commands:
	if not c:
		c = Goon.Commands.new()
	c.walk = Input.get_axis("go left","go right")
	return c

func _process(delta):
	Engine.time_scale = 0.1 if Input.is_action_pressed("slomo") else 1.0

	if player_character:
		player_character.command(get_commands())
		global_position = player_character.global_position

func event_position(ev: InputEvent) -> Vector2:
	if ev is InputEventMouse or ev is InputEventScreenTouch:
		return Yute.viewport_to_world(ev.position, player_character)
	# idk what to do here, we'll have to see
	if "position" in ev:
		return player_character.global_position + ev.position
	return player_character.global_position

func quick_move_item(ev: InputEvent, direction: int):
	var items = Clision.get_objects_at(event_position(ev), "interactive") + Clision.get_objects_at(event_position(ev), "characters")
	print(items)
	if not items:
		return

	if items[0] is Gourt:
		return items[0].move_equipment(direction)

	var equipment_owner = Gourtilities.get_equipment_owner(items[0])
	if equipment_owner:
		return equipment_owner.move_equipment(direction, items[0])

func _input(ev: InputEvent):
	#don't consume probe events, let the goon handle them directly
	if not ev.is_action_pressed("probe"):
		get_viewport().set_input_as_handled()

	if ev.is_action_pressed("interact"):
		var ev_pos = event_position(ev)
		var interactables = Clision.get_objects_at(ev_pos, "interactive")
		if interactables:
			player_character. _interact(interactables[0], ev_pos) #TODO we should try to handle the whole array not just whatever is arbitrarily the first element
	elif ev.is_action_pressed("move equipment up"):
		quick_move_item(ev, Direction.UP)
	elif ev.is_action_pressed("move equipment down"):
		quick_move_item(ev, Direction.DOWN)
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
