extends Camera2D
class_name Master #TODO: this class should be more generic: player and AI should inheret from it

@export var player_character: Goon:
	set(g):
		assert(valid_goon(g))
		if valid_goon(player_character):
			player_character.under_new_management(null)
		g.under_new_management(self)
		player_character = g

func valid_goon(g: Goon) -> bool:
	return g and is_instance_valid(g)

func screen_position(world_position: Vector2):
	return get_viewport().get_screen_transform() * get_global_transform_with_canvas() * world_position

func _ready():
	#move to bottom of tree to recieve inputs first among siblings.
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
	player_character.command(get_commands())
	global_position = player_character.global_position

func _input(ev: InputEvent):
	get_viewport().set_input_as_handled()
	player_character._input(ev)

func nominate(g: Goon):
	player_character = g
