extends Camera2D
class_name Master #TODO: this class should be more generic: player and AI should inheret from it

@export var player_character: Goon:
	set(g):
		if player_character:
			player_character.under_new_management(null)
		g.under_new_management(self)
		player_character = g

func _ready():
	#move to bottom of tree to recieve inputs first among siblings.
	get_parent().move_child.call_deferred(self, -1)
	player_character.under_new_management(self)

func _input(ev: InputEvent):
	print(ev.as_text())
	get_viewport().set_input_as_handled()
	if player_character:
		player_character._input(ev)

func nominate(g: Goon):
	player_character = g

