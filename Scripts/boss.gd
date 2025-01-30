extends CharacterBody2D

@onready var detection_area: Area2D = $detection_area

var SPEED = 30.00
var detected = false
var direction = Vector2.ZERO
var target: Node2D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		direction = global_position.direction_to(target.global_position)
	
	velocity = direction * SPEED
	
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		target = body
		direction =  global_position.direction_to(body.global_position)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
