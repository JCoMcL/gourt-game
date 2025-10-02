@icon("res://ui/cursor/cursor.png")
extends CanvasItem
class_name Cursor

@export_group("Atlas Properties")
@export var passive_spritesheet: Texture2D
@export var pointive_spritesheet: Texture2D
@export var region_size = 64
@export var anchor_point_offset = 16
var anchor_point = Vector2i(anchor_point_offset, anchor_point_offset)

@export_group("Settings")
@export var passive_frametime = 0.6 #seconds
@export var pointive_frametime = 0.3 #seconds
@export_range(0, TAU) var angle = PI * 1.5:
	set(val):
		while val < 0:
			val += TAU
		val = fmod(val, TAU) # modulo for floats, % only works in integers
		angle = val

func new_atlas_texture(atlas: Texture2D) -> HandyAtlas:
	var a = HandyAtlas.new()
	a.atlas = atlas
	a.region.size = Vector2.ONE * region_size
	return a

var cursors: Array[AnimatedCursor]
func _ready():
	cursors = [
		AnimatedCursor.new(
			new_atlas_texture(passive_spritesheet),
			Input.CURSOR_ARROW,
			passive_frametime,
			anchor_point_offset
		),
		AnimatedCursor.new(
			new_atlas_texture(pointive_spritesheet),
			Input.CURSOR_POINTING_HAND,
			pointive_frametime,
			anchor_point_offset
		)
	]

class AnimatedCursor:
	var tex: HandyAtlas
	var cursor_type: Input.CursorShape
	var frame_time: float
	var anchor_point_offset: int
	var anchor_point: Vector2i

	func _init(tex: HandyAtlas, cursor_type: Input.CursorShape, frame_time: float, anchor_point_offset: int):
		self.tex = tex
		self.cursor_type = cursor_type
		self.frame_time = frame_time
		self.anchor_point_offset = anchor_point_offset
		anchor_point = Vector2i(anchor_point_offset, anchor_point_offset)
		assert(tex.atlas)
		update()

	func update():
		if Input.get_current_cursor_shape() == cursor_type:
			if Platform.current.requires_cursor_wangling:
				Input.set_custom_mouse_cursor(null, cursor_type, anchor_point)
			Input.set_custom_mouse_cursor(tex, cursor_type, anchor_point)

	var angle_index: int = -1
	func set_angle(angle: float):
		var new_angle_index = int(angle * 12 / TAU)
		if new_angle_index != angle_index:
			angle_index = new_angle_index
			tex.set_xy(angle_index, null)

			var w = int(tex.region.size.x)
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
			update()

	var frame_time_acc = 0
	func add_time(delta: float):
		frame_time_acc += delta
		if frame_time_acc >= frame_time:
			frame_time_acc -= frame_time
			tex.add_xy(0,1)
			update()

var current_cursor_type: Input.CursorShape = Input.CURSOR_ARROW
var time_accum = 0.0
func _process(delta):
	time_accum += delta
	if time_accum < Platform.current.min_cursor_update_delay:
		return
	time_accum = 0.0

	angle = get_viewport().get_visible_rect().get_center().angle_to_point(get_viewport().get_mouse_position())

	for c in cursors:
		if c.cursor_type == Input.get_current_cursor_shape():
			c.set_angle(angle)
			c.add_time(delta)

func _physics_process(delta: float) -> void:
	var interactables_under_cursor = Clision.get_objects_at(
		Yute.viewport_to_world(get_viewport().get_mouse_position()),
		"interactive"
	)

	if interactables_under_cursor:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape()
