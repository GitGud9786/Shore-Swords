extends CharacterBody2D

var DAMAGE = 50.0
var SPEED = 500.0
var starting_direction = Vector2.ZERO
var direction = Vector2.ZERO
var landing_location = Vector2.ZERO

func set_landing_location(vector):
	landing_location = vector
	direction = global_position.direction_to(landing_location)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_direction = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.distance_to(starting_direction)<1000.0:
		velocity = direction * SPEED
		rotation = direction.angle()	
		move_and_slide()
		
	else: #reached target location
		velocity = Vector2.ZERO
		queue_free()


func _on_attack_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		body.take_damage(DAMAGE)
