extends Node2D

@export var dialogue_entries: Array[CharacterDialogueData] = []
@export var dialogue_area: Area2D
@export var dialogue_ui: DialogueUI

var dialogue_counter = 0

func _ready():
	print(dialogue_entries[dialogue_counter].dialogue_id)
	print(dialogue_entries[dialogue_counter].character_path)
	if dialogue_area:
		dialogue_area.input_event.connect(_on_input_event)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Area clicked!")
		show_dialogue()

func show_dialogue():
	var character: Node = get_node(dialogue_entries[dialogue_counter].character_path)
	if character:
		var global_position = character.get_global_position()
		dialogue_ui.show_text_at(global_position, dialogue_entries[dialogue_counter].dialogue_id)
		if dialogue_counter < dialogue_entries.size():
			dialogue_counter+=1
