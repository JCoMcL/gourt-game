extends Node2D

@export var dialogue_entries: Array[CharacterDialogueData] = []
@export var dialogue_area: Area2D
@export var dialogue_ui: DialogueUI
@export var camera_focus: NodePath

var dialogue_counter = -1
var dialogue_triggered = false

func _ready():
	print(dialogue_entries[dialogue_counter].dialogue_id)
	print(dialogue_entries[dialogue_counter].character_path)
	if dialogue_area:
		dialogue_area.input_event.connect(_on_input_event)

func _process(delta):
	if dialogue_triggered and dialogue_counter < dialogue_entries.size():
		var character: Node = get_node(dialogue_entries[dialogue_counter].character_path)
		var camera_focus_pos = get_node_or_null(camera_focus) # Use the assignable camera focus node
		if camera_focus_pos and character:
			var dialogue_global_position = (character.get_global_position() + camera_focus_pos.get_global_position()) / 2.0
			dialogue_ui.show_text_at(dialogue_global_position, dialogue_entries[dialogue_counter].dialogue_id)
			# Draw line between character and camera focus
			dialogue_ui.draw_line(character.get_global_position(), camera_focus_pos.get_global_position(), Color(1, 0, 0))
		else:
			print("Camera focus node or character not found.")

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Area clicked!")
		if dialogue_counter < dialogue_entries.size():
			dialogue_triggered = true
			dialogue_counter += 1
