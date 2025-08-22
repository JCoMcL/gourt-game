extends Area2D

signal on_pressed

func interact(operator) -> bool:
	on_pressed.emit()
	return true
	
