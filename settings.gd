@tool
extends Node

var text_speed = 20.0
func text_duration(s: String):
	return (s.length()) / text_speed
