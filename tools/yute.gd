@tool
extends Node

func snap_force(initial:Vector2, direction:Vector2, delta:float, snappiness:float = 300, sharpness:float = 0.3) -> Vector2:
	return initial.move_toward(direction * sharpness / (delta / Engine.time_scale), snappiness) - initial #TODO refactor

# --- space, shape, and coordinates ---

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
	var vp = relative_to.get_viewport()
	return vp.global_canvas_transform.affine_inverse() * vp.canvas_transform.affine_inverse() * v

func get_viewport_world_rect(relative_to: Node = self) -> Rect2:
	var r = relative_to.get_viewport().get_visible_rect()
	var start = viewport_to_world(r.position, relative_to)
	var end = viewport_to_world(r.end, relative_to)
	return Rect2(start, end - start)

func four_corners(r: Rect2) -> Array[Vector2]:
	return [
		r.position,
		Vector2(r.position.x, r.end.y),
		r.end,
		Vector2(r.end.x, r.position.y)
	]

func nearest_overlapping_position(inner: Rect2, outer: Rect2) -> Vector2:
	if outer.encloses(inner):
		return inner.position

	# return inner's position plus the offset of the furthest vertex from outer
	var out = four_corners(inner).filter(func(p):
		return not outer.has_point(p) #only outside points
	).map(func(v):
		return get_nearest_point_on_perimeter(outer, v) - v
	).reduce(func(v:Vector2, longest):
		return v if v.length_squared() > longest.length_squared() else longest
	) * 1.01 + inner.position

	#test that it works
	var new_inner = Rect2(out, inner.size)
	assert(outer.encloses(new_inner))
	return out

# --- nodes ---

func find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		var found = find_node_by_name(child, target_name)
		if found:
			return found
	return null

func replace_node(current_node, new_node, parent):
	var index = parent.get_children().find(current_node)
	current_node.queue_free()
	if new_node:
		var n = new_node.instantiate()
		print("instantiated: ", n.name, " at ", n.global_position)
		parent.add_child(n)
		parent.move_child(n, index)
		n.global_position = parent.global_position

# --- random ---

var rng = RandomNumberGenerator.new()
func triangular_distribution(lower: float = -1.0, upper: float = 1.0) -> float:
	return rng.randf_range(upper, lower) + rng.randf_range(upper, lower)

func percent_chance(i):
	return rng.randf() * 100 < i

func cointoss():
	return randf() < 0.5

