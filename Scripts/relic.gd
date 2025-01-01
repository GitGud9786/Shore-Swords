extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_relic_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		queue_free()
