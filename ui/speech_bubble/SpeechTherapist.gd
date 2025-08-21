extends Node

var bubbles = {}
@export var speech_bubble: PackedScene
func _ready():
	speech_bubble = load("%s/speech_bubble.tscn" % get_script().get_path().get_base_dir())

func say(speaker: Node2D, words: String) -> SpeechBubble:
	var sb: SpeechBubble
	if bubbles.has(speaker) and is_instance_valid(bubbles[speaker]):
		sb = bubbles[speaker]
		sb.add_text(words)
	else:
		sb = speech_bubble.instantiate()
		sb.auto_expire = true
		speaker.add_child(sb)
		sb.speaker = speaker
		bubbles[speaker] = sb
		sb.anneal_position()
		sb.text = words
	return sb
