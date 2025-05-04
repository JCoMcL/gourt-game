extends Node
class_name Character

@export var character_name: String = "Unnamed"
@export var has_spoken: bool = false

func speak(dialogue_text: String) -> void:
	print("%s says: %s" % [character_name, dialogue_text])
	has_spoken = true
