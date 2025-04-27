extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body: Node):
	if body is CharacterBody2D:
		body.yeetonate()
		print("%s had left the scene" % body.name)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
