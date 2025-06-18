@tool
extends Line2D

@onready var bubble: SpeechBubble = get_parent()

func nearest(f:float, a:float, b:float):
	return a if abs(f-a) < abs(f-b) else b

func local_rect(o: Node):
	var sh = o.get_node_or_null("Handle/Speak Hole") #TODO this should definitely be a method on the speaker
	if sh:
		return local_rect(sh)
	if o.has_method("get_rect"):
		var r = o.get_rect()
		var pos = o.global_position - (r.size/2 if o is Sprite2D else Vector2.ZERO)
		return Rect2(to_local(pos), r.size)
	else:
		print("not implemented :(") #FIXME?

func _process(delta):
	if bubble.speaker:
		set_point_position(1, Yute.get_nearest_point_on_perimeter(
			local_rect(bubble.speaker),
			to_local(bubble.global_position) + Vector2(bubble.size) * 0.8
		))

	set_point_position(0, Yute.get_nearest_point_on_perimeter(
		Rect2(Vector2.ZERO, bubble.get_rect().size),
		get_point_position(1)
	))
