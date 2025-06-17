@tool
extends Line2D

@onready var bubble: SpeechBubble = get_parent()

func nearest(f:float, a:float, b:float):
	return a if abs(f-a) < abs(f-b) else b

func get_nearest_point_on_perimeter(r: Rect2, p: Vector2):
	p.x =  clampf(p.x, r.position.x, r.end.x)
	p.y =  clampf(p.y, r.position.y, r.end.y)
	var nearest_x = nearest(p.x, r.position.x, r.end.x)
	var nearest_y = nearest(p.y, r.position.y, r.end.y)
	if abs(p.x - nearest_x) > abs(nearest_y - p.y):
		return Vector2(p.x, nearest_y)
	else:
		return Vector2(nearest_x, p.y)

func local_rect(o: Node):
	if o.has_method("get_rect"):
		var r = o.get_rect()
		return Rect2(to_local(o.global_position - r.size/2), r.size)
	else:
		print("not implemented :(") #FIXME?

func _process(delta):
	if bubble.speaker:
		set_point_position(1, get_nearest_point_on_perimeter(
			local_rect(bubble.speaker),
			to_local(bubble.global_position) + Vector2(bubble.size) * 0.8
		))

	set_point_position(0, get_nearest_point_on_perimeter(
		Rect2(Vector2.ZERO, bubble.get_rect().size),
		get_point_position(1)
	))
