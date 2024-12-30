extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_collision: Area2D = $attack_area_collision

var landing_location = Vector2.ZERO
var SPEED = 250
var ROTATION_SPEED = 10.0
var DAMAGE = 10
var explode_start_frame = 2
var explode_end_frame = 4
var explosion_end = false
var direction = Vector2.ZERO

func get_explode_status():
	return explosion_end

func set_landing_location(vector):
	landing_location = vector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.distance_to(landing_location)>5.0:
		direction = global_position.direction_to(landing_location)
		velocity = direction * SPEED
		move_and_slide()
		rotation += delta * ROTATION_SPEED
		
	else: #reached target location
		velocity = Vector2.ZERO
		animated_sprite.play("tnt_explode")


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation=="tnt_explode":
		explosion_end = true
		queue_free()


func _on_attack_area_collision_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"): #detect both players and enemies
		body.take_damage(DAMAGE)


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation == "tnt_explode":
		if animated_sprite.frame == explode_start_frame:
			attack_area_collision.monitoring=true
		elif animated_sprite.frame == explode_end_frame:
			attack_area_collision.monitoring = false
			
