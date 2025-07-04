extends Node

enum {UP, DOWN, LEFT, RIGHT, NONE}

func pretty(i:int):
	return ["up", " down", " left", " right", "none"][i]

func test_spread(f: float, within: float, of: float) -> bool:
	return (of - within) < f and f < (of + within)

func get_strict_direction(to: Vector2):
	var angle = rad_to_deg(to.angle()) + 155
	if test_spread(angle, 30, 65):
		return UP
	if test_spread(angle, 20, 155):
		return RIGHT
	if test_spread(angle, 30, 245) :
		return DOWN
	if test_spread(angle, 20, 340):
		return LEFT
	return NONE

func get_x(x: float, deadzone=0.0):
	if absf(x) < deadzone: return NONE
	return RIGHT if x > 0 else LEFT
func get_y(y: float, deadzone=0.0):
	if absf(y) < deadzone: return NONE
	return UP if y > 0 else DOWN #WARN untested
func get_direction(v: Vector2, deadzone=0.0):
	if absf(v.x) > absf(v.y):
		return get_x(v.x, deadzone)
	return get_y(v.y, deadzone)

