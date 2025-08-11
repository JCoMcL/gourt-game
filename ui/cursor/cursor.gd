@icon("res://ui/cursor/cursor.png")
extends CanvasItem
class_name Cursor

@export_group("Atlas Properties")
@export var passive_spritesheet: Texture2D
@export var region_size = 64
@export var anchor_point_offset = 16
var anchor_point = Vector2i(anchor_point_offset, anchor_point_offset)

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
	angle = angle
	update_cursor()

func update_cursor():
	Input.set_custom_mouse_cursor(null)
	Input.set_custom_mouse_cursor(tex,0,anchor_point)

func get_xy() -> Vector2i:
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
var angle_index = 0
func _process(delta):
	frame_time_acc += delta
	if frame_time_acc >= frametime:
		frame_time_acc -= frametime
		add_xy(0,1)
		print(get_xy())
		update_cursor()

	angle = get_viewport().get_visible_rect().get_center().angle_to_point(get_viewport().get_mouse_position())
	var _angle_index = int(angle * 12 / TAU)
	if _angle_index != angle_index:
		set_xy(_angle_index, null)
		angle_index = _angle_index

		var w = region_size
		var o = anchor_point_offset
		match angle_index:
			0,1,2:
				anchor_point = Vector2i(w-o, w-o)
			3,4,5:
				anchor_point = Vector2i(o, w-o) #what's this?
			6,7,8:
				anchor_point = Vector2i(o, o)
			9,10,11:
				anchor_point = Vector2i(w-o, o)
		update_cursor()
