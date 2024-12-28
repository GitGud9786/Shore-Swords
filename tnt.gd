extends Node2D

var landing_location = Vector2.ZERO
var SPEED = 1

func set_landing_location(vector):
	landing_location = vector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.distance_to(landing_location)>20:
		velocity = global_position.direction_to(landing_location) * SPEED
