class_name HandyAtlas
extends AtlasTexture

func get_xy() -> Vector2i:
	return Vector2i(
		region.position / region.size
	)

func set_xy(x, y):
	if x is int and y is int:
		region.position = Vector2(
			int(region.size.x * x) % atlas.get_width(),
			int(region.size.y * y) % atlas.get_height(),
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
