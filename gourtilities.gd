@tool
extends Node

# TODO: this uses local position, which may cause weird behaviour.
# A more robust implementation would give global position and require the caller to transform it to their local
func perch_position(o: Node2D) -> Vector2: 
	var p = o.get_node_or_null("Perch")
	return o.position + (p.position if p else Vector2.UP * 100)

func stack(g: Gourt, onto: Gourt): #BUGMAGNET gourt neighbour
	g.foot_friend = onto
	onto.head_friend = g

func stack_now(g: Gourt, onto: Gourt):
	stack(g, onto)
	g.position = perch_position(onto)
