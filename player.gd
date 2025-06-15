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

func screen_position(world_position: Vector2):
	return get_viewport().get_screen_transform() * get_global_transform_with_canvas() * world_position

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

func _input(ev: InputEvent):
	if not ev.is_action_pressed("probe"): #don't consume probe events, let the goon handle them directly
		get_viewport().set_input_as_handled()
	if ev.is_action_pressed("interract"):
		var pq := PhysicsPointQueryParameters2D.new()
		pq.collide_with_areas = true
		pq.collide_with_bodies = true
		pq.collision_mask = 32
		pq.exclude = []
		pq.position = get_global_mouse_position() #TODO see if we can not rely on mouse clicking		
		var result = get_world_2d().direct_space_state.intersect_point(pq)
		if result.size() == 0:
			print("nothing detected")
		else:
			print(result[0])
			player_character.interract(result[0].collider)

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
