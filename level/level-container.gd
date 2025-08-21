extends Node2D
class_name LevelContainer
@export var current_level_scene: PackedScene
var current_level: Node

func _ready():
	if not current_level and current_level_scene:
		load_scene(current_level_scene)
	$Overlay/Curtain.open(2)

func load_scene(scn: PackedScene):
	if current_level:
		current_level.queue_free()
		remove_child(current_level)
	current_level_scene = scn
	current_level = scn.instantiate()
	add_child(current_level)
	$Overlay/Curtain.open()

func reset_level():
	$Overlay/Curtain.close().tween_callback(load_scene.bind(current_level_scene))
