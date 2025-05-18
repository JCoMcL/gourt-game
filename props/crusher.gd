extends AnimatableBody2D

@export var speed = 2.0
@export var range = Vector2(100, -100)

var time = 0
var initial: Vector2
func _physics_process(delta: float) -> void:
	time += delta
	position = initial + sin(time * speed) * range

func _ready() -> void:
	initial = position
	
