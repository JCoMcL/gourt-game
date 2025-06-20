@tool
extends Node2D

@export var enabled: bool:
	set(value):
		enabled = value
		process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED

@onready var sprite: Sprite2D = get_parent()
@onready var height_vec = Vector2(0, -sprite.get_rect().size.y / 2)

func _ready() -> void:
	global_position = sprite.global_position + height_vec

func grow_factor():
	return absf(position.x) / 500 + (position.y - height_vec.y) / 500

func _process(delta) -> void:
	if ! enabled:
		return
	sprite.material.set_shader_parameter("handle", position - height_vec)
	sprite.material.set_shader_parameter("grow", grow_factor())
