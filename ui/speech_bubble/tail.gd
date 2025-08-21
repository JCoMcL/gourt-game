@tool
extends Line2D

@onready var bubble: SpeechBubble = get_parent()

func nearest(f:float, a:float, b:float):
	return a if abs(f-a) < abs(f-b) else b

func speaker_local_rect(o: Node) -> Rect2:
	var mouth = Yute.find_node_by_name(o, "Speak Hole")
	var r = Yute.get_global_rect(mouth if mouth else o)
	r.position -= global_position
	return r

func _process(delta):
	if not bubble:
		return
	if bubble.speaker:
		set_point_position(1, Yute.get_nearest_point_on_perimeter(
			speaker_local_rect(bubble.speaker),
			to_local(bubble.global_position) + Vector2(bubble.size) * 0.8
		))

	set_point_position(0, Yute.get_nearest_point_on_perimeter(
		Rect2(Vector2.ZERO, bubble.get_rect().size),
		get_point_position(1)
	))
