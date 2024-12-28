extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_collision: Area2D = $attack_area_collision

var landing_location = Vector2.ZERO
var SPEED = 150
var DAMAGE = 10

func set_landing_location(vector):
	landing_location = vector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("Landing location: ", landing_location)
	if global_position.distance_to(landing_location)>5.0:
		print("Came here")
		velocity = global_position.direction_to(landing_location) * SPEED
		move_and_slide()
	else: #reached target location
		velocity = Vector2.ZERO
		attack_area_collision.monitoring=true
		animated_sprite.play("tnt_explode")


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation=="tnt_explode":
		attack_area_collision.monitoring = false
		queue_free()


func _on_attack_area_collision_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"): #detect both players and enemies
		body.take_damage(DAMAGE)
