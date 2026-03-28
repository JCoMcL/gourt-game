@tool
class_name ActorHandle
extends Node2D

@export var enabled: bool:
	set(value):
		enabled = value
		process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
@export_tool_button("Reset", "Reload") var fre = set_offset

@export var talking=false

@onready var sprite: Sprite2D = get_parent()
@onready var height_vec = Vector2(0, -sprite.get_rect().size.y / 2)

func set_offset(v:Vector2):
	global_position = sprite.global_position + (height_vec + v) * global_scale

func _ready() -> void:
	set_offset(Vector2.ZERO)

func grow_factor():
	return absf(position.x) / 500 + (position.y - height_vec.y) / 500

var secs = 0.0
func _process(delta) -> void:
	if not enabled:
		return
	sprite.material.set_shader_parameter("handle", position - height_vec)
	sprite.material.set_shader_parameter("grow", grow_factor())
	if talking:
		secs += delta
		set_offset(talk(secs))

# --- animations ---
func _talk(t: float) -> Vector2:
	var bob_speed: float = 14
	var bounce_amp: float = 0.3
	var sway_amp: float = 0.9
	var rand_amp: float = 0.2

	var bob_raw: float = sin(t * bob_speed + sin(t) * bounce_amp)
	var bounce: float = -abs(sin(t * bob_speed * 0.5)) * bounce_amp * 2.0
	var sway: float = sin(t * 1.5 + sin(t) * 0.5) * (3.0 + sin(t / 2.0)) * sway_amp

	var noise_x: float = (sin(t * 7.13) + sin(t * 3.77) + sin(t * 11.31)) * rand_amp
	var noise_y: float = (sin(t * 5.91) + sin(t * 8.43) + sin(t * 2.61)) * rand_amp

	return Vector2(sway + noise_x, -(bounce + bob_raw + noise_y)) * 20.0

func talk(t: float) -> Vector2:
	return _talk(t + max(sin(t * 1.13) * 0.4, sin(t * 0.47) * 0.7))
