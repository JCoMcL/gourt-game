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
# call
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

# list
func list_head_friends(g: Gourt, acc: Array[Gourt] = []) -> Array[Gourt]:
	if g.head_friend:
		acc.append(g.head_friend)
		return list_head_friends(g.head_friend, acc)
	return acc

func list_foot_friends(g: Gourt, acc: Array[Gourt] = []) -> Array[Gourt]:
	if g.foot_friend:
		acc.append(g.foot_friend)
		return list_foot_friends(g.foot_friend, acc)
	return acc

func list_stack_members(g: Gourt):
## note that the returned list is in no particular order
	return list_foot_friends(g) + [g] + list_head_friends(g)

# --- Recursive functions ---

func resolve_perch(g: Gourt):
	call_all_upwards(g, func(g: Gourt):
		if g.foot_friend:
			g.position = perch_position(g.foot_friend)
	)

func head_count(g: Gourt):
	return list_head_friends(g).size()

func foot_count(g: Gourt):
	return list_foot_friends(g).size()

func stack_count(g: Gourt):
	return head_count(g) + foot_count(g) + 1

func get_stack_tip(g: Gourt):
	return list_head_friends(g)[-1] if g.head_friend else g

func is_descendant(child: Node, potential_parent: Node) -> bool:
	var current = child.get_parent()
	while current:
		if current == potential_parent:
			return true
		current = current.get_parent()
	return false

func get_equipment_owner(equipment) -> Gourt:
	if not equipment or not equipment is Node:
		return null
	var parent = equipment.get_parent()
	while parent and parent is Node:
		if parent is Gourt:
			return parent
		parent = parent.get_parent()
	return null
