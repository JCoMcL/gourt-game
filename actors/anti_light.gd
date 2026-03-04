extends Light2D

@export var darkness_strength: float = 1.0
@export var radius: float = 100.0

func _ready():
	# Set up the light as a subtractive light for darkness effect
	blend_mode = Light2D.BLEND_MODE_SUB
	energy = darkness_strength
	texture_scale = radius / 64.0  # Assuming default texture size, adjust as needed
	
	# Use a simple radial gradient texture for the light shape
	# In Godot, you might need to assign a texture in the editor or create one programmatically
	pass

func _process(delta):
	# Optional: Add any dynamic behavior here
	pass