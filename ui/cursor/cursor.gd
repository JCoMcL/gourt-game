@icon("res://ui/cursor/cursor.png")
extends Node
class_name Cursor

@export_group("Atlas Properties")
@export var passive_spritesheet: Texture2D
@export var region_size = 64
@export var anchor_point = Vector2i(16,16)

@export_group("Settings")
@export var frametime = 0.5 #seconds
@export_range(0, TAU) var angle = PI * 1.5:
	set(val):
		while val < 0:
			val += TAU
		val = fmod(val, TAU) # modulo for floats, % only works in integers
		angle = val

func new_atlas_texture(atlas: Texture2D) -> AtlasTexture:
	var a = AtlasTexture.new()
	a.atlas = atlas
	a.region.size = Vector2.ONE * region_size
	return a

var tex: AtlasTexture
func _ready():
	tex = new_atlas_texture(passive_spritesheet)

	assert(get_xy() == other_get_xy())

	update_cursor()

func update_cursor():
	Input.set_custom_mouse_cursor(null)
	Input.set_custom_mouse_cursor(tex,0,anchor_point)

func get_xy() -> Vector2i:
	return Vector2i(
		tex.region.position.x / tex.region.size.x,
		tex.region.position.x / tex.region.size.y
	)

func other_get_xy() -> Vector2i:
	return Vector2i(
		tex.region.position / tex.region.size
	)

func set_xy(x, y):
	if x is int and y is int:
		tex.region.position = Vector2(
			int(tex.region.size.x * x) % tex.atlas.get_width(),
			int(tex.region.size.y * y) % tex.atlas.get_height(),
		)
	else:
		var xy = get_xy()
		set_xy(
			x if x is int else xy.x,
			y if y is int else xy.y
		)

func add_xy(x, y):
	var xy = get_xy()
	set_xy(xy.x + x, xy.y + y)

var frame_time_acc = 0
func _process(delta):
	frame_time_acc += delta
	if frame_time_acc >= frametime:
		frame_time_acc -= frametime
		add_xy(0,1)
		update_cursor()
