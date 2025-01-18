extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_collision: Area2D = $attack_area_collision

var landing_location = Vector2.ZERO
var SPEED = 1000.0
var BASE_DAMAGE = 70.0
var explosion_end = false
var direction = Vector2.ZERO
var starting_direction = Vector2.ZERO
var max_distance = 500.0

func set_landing_location(vector):
	landing_location = vector
	direction = global_position.direction_to(landing_location)

func _ready() -> void:
	starting_direction = global_position

func _process(delta: float) -> void:
	if global_position.distance_to(starting_direction)<500.0:
		velocity = direction * SPEED
		rotation = direction.angle()	
		move_and_slide()
		
	else: #reached target location
		velocity = Vector2.ZERO
		queue_free()

func _on_attack_area_collision_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var current_distance = global_position.distance_to(starting_direction)
		var distance_factor = 1.0 - (current_distance/max_distance)
		
		if distance_factor < 0.0:
			distance_factor = 0.0 
		var DAMAGE = BASE_DAMAGE * distance_factor
		body.take_damage(DAMAGE)
		queue_free()
