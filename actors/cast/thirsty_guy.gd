extends Actor

func _ready():
	collision_layer |= Clision.layers["player_wall"]
