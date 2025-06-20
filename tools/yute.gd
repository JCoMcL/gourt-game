@tool
extends Node

func snap_force(initial:Vector2, direction:Vector2, delta:float, snappiness:float = 300, sharpness:float = 0.3) -> Vector2:
	return initial.move_toward(direction * sharpness / (delta / Engine.time_scale), snappiness) - initial #TODO refactor

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

func viewport_to_world(v: Vector2, relative_to: Node = self):
	return relative_to.get_viewport().global_canvas_transform.affine_inverse() * v

func get_viewport_world_rect(relative_to: Node = self) -> Rect2:
	var r = relative_to.get_viewport().get_visible_rect()
	var start = viewport_to_world(r.position, relative_to)
	var end = viewport_to_world(r.end, relative_to)
	return Rect2(start, end - start)
