@tool
extends Node

func get_intersection_points(collision_mask, position, collide_with_areas  = true, collide_with_bodies = true):
	var pq := PhysicsPointQueryParameters2D.new()
	pq.collide_with_areas = collide_with_areas
	pq.collide_with_bodies = collide_with_bodies
	pq.collision_mask = collision_mask
	pq.exclude = []
	pq.position = position #TODO see if we can not rely on mouse clicking		
	return get_viewport().get_world_2d().direct_space_state.intersect_point(pq)

func get_collider_at_point(collision_mask, position):
	var points = get_intersection_points(collision_mask, position)
	if points.size() == 0:
		print("nothing detected")
	else:
		return points[0].collider