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

func get_character_at_event(ev: InputEvent) -> Gourt:
	var characters = Clision.get_objects_at(event_position(ev), "characters")
	if characters.size():
		return characters[0]
	return null

func _input(ev: InputEvent):
	#don't consume probe events, let the goon handle them directly
	if not ev.is_action_pressed("probe"):
		get_viewport().set_input_as_handled()

	if ev.is_action_pressed("interact"):
		var interactables = Clision.get_objects_at(event_position(ev), "interactive")
		if interactables:
			player_character.interact(interactables[0]) #TODO we should try to handle the whole array not just whatever is arbitrarily the first element
	elif ev.is_action_pressed("move equipment up"):
		var c = get_character_at_event(ev) #FIXME this lets us control all characters, not just our player character
		if c:
			c.move_equipment_up()
	elif ev.is_action_pressed("move equipment down"):
		var c = get_character_at_event(ev)
		if c:
			c.move_equipment_down()
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
