extends Node

var current = PlatformSpec.new()

class PlatformSpec:
	var requires_cursor_wangling = false
	var min_cursor_update_delay = 0

class Windows extends PlatformSpec:
	pass

class Linux extends PlatformSpec:
	# TODO much of the specifics here depend on DisplayServer, not OS
	func _init():
		requires_cursor_wangling = true


func _ready():
	match OS.get_name():
		"Linux":
			current = Linux.new()
		"Windows":
			current = Windows.new()
	#print(DisplayServer.get_name())

