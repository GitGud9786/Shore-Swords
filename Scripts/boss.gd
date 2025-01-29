extends CharacterBody2D

var SPEED = 10.0
var direction = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(direction)
	velocity = direction * SPEED
	
	move_and_slide()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		print("player located")
		direction =  global_position.direction_to(body.global_position)
