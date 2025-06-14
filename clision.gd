extends Node

var layers: Dictionary[String, int]:
	get():
		if ! layers:
			for i in range(32):
				var layer_name = ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % i)
				if layer_name:
					layers[layer_name] = 2 ** (i-1)
		return layers

enum {AREAS, BODIES, AREAS_AND_BODIES}
func intersect_point(you: CanvasItem, where: Vector2, mask=65535, collider_type=AREAS_AND_BODIES):
	var pq := PhysicsPointQueryParameters2D.new()
	pq.collide_with_areas = (collider_type == AREAS || collider_type == AREAS_AND_BODIES)
	pq.collide_with_bodies = (collider_type == BODIES || collider_type == AREAS_AND_BODIES)
	pq.collision_mask = layers[mask] if mask is String else mask
	pq.position = where

	return you.get_world_2d().direct_space_state.intersect_point(pq)
