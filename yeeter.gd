extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body: Node):
	if body is CharacterBody2D:
		body.yeetonate()
		print("%s had left the scene" % body.name)
		#body.queue_free()
		collision_shape.queue_free()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
