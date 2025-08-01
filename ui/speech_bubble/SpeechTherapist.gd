extends Node

var bubbles = {}
@export var speech_bubble: PackedScene
func _ready():
	speech_bubble = load("%s/speech_bubble.tscn" % get_script().get_path().get_base_dir())

func say(speaker: Node2D, words: String) -> SpeechBubble:
	var sb: SpeechBubble
	if bubbles.has(speaker):
		sb = bubbles[speaker]
	else:
		sb = speech_bubble.instantiate()
		speaker.get_tree().get_root().add_child(sb)
		sb.speaker = speaker
		bubbles[speaker] = sb
	sb.text = words
	sb.anneal_position(50)
	return sb
