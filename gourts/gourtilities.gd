@tool
extends Node

func perch_position(o: Node2D) -> Vector2: 
	var p = o.get_node_or_null("Perch")
	return o.position + (p.position if p else Vector2.UP * 100)

func global_perch_position(o: Node2D) -> Vector2:
	var p = o.get_node_or_null("Perch")
	return p.global_position

func stack(g: Gourt, onto: Gourt): #BM1
	g.foot_friend = onto
	if onto.head_friend:
		stack(onto.head_friend, g)
	onto.head_friend = g

func stack_now(g: Gourt, onto: Gourt):
	var former_head_friend = onto.head_friend
	stack(g, onto)
	resolve_perch(g)
	if former_head_friend:
		resolve_perch(former_head_friend)

func resolve_perch(g: Gourt):
	if g.foot_friend:
		g.position = perch_position(g.foot_friend)
	if g.head_friend:
		resolve_perch(g.head_friend)

func head_count(g: Gourt):
	if g.head_friend:
		return 1 + head_count(g.head_friend)
	return 0

func foot_count(g: Gourt):
	if g.foot_friend:
		return 1 + foot_count(g.foot_friend)
	return 0

func get_stack_tip(g: Gourt):
	if g.head_friend:
		return get_stack_tip(g.head_friend)
	return g
