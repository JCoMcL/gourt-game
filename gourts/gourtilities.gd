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

# --- Recursive helpers ---
func call_all_downwards(g: Gourt, f: Callable):
	f.call(g)
	if g.foot_friend:
		call_all_downwards(g.foot_friend, f)

func call_all_upwards(g: Gourt, f: Callable):
	f.call(g)
	if g.head_friend:
		call_all_upwards(g.head_friend, f)

func call_all(g: Gourt, f: Callable):
	f.call(g)
	if g.foot_friend:
		call_all_downwards(g.foot_friend, f)
	if g.head_friend:
		call_all_upwards(g.head_friend, f)

# --- Recursive functions ---

func resolve_perch(g: Gourt):
	call_all_upwards(g, func(g: Gourt):
		if g.foot_friend:
			g.position = perch_position(g.foot_friend)
	)

func head_count(g: Gourt):
	if g.head_friend:
		return 1 + head_count(g.head_friend)
	return 0

func foot_count(g: Gourt):
	if g.foot_friend:
		return 1 + foot_count(g.foot_friend)
	return 0

func stack_count(g: Gourt):
	return head_count(g) + foot_count(g) + 1

func get_stack_tip(g: Gourt):
	if g.head_friend:
		return get_stack_tip(g.head_friend)
	return g
