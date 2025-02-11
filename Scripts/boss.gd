extends CharacterBody2D

@onready var detection_area: Area2D = $detection_area
@onready var beam: PackedScene = preload("res://Scenes/laser_beam.tscn")
@onready var attack_area_collision: Area2D = $AnimatedSprite2D/attack_area_collision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var SPEED = 30.00
var DAMAGE = 60.00
var detected = false
var direction = Vector2.ZERO
var target: Node2D = null
var attack_start_frame = 5
var attack_end_frame = 6
var attack_mode = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		direction = global_position.direction_to(target.global_position)
	if direction.x < 0:
		animated_sprite.flip_h = true 
	elif direction.x > 0:
		animated_sprite.flip_h = false
	
	if target and !attack_mode and global_position.distance_to(target.global_position) > 100.0:
		animated_sprite.play("golem_idle")
		velocity = direction * SPEED
		move_and_slide()
	else: #reached melee range
		velocity = Vector2.ZERO
		attack_protagonist()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		target = body
		direction =  global_position.direction_to(body.global_position)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		
func attack_protagonist():
	animated_sprite.play("golem_melee")
	attack_mode = true

func _on_attack_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		body.take_damage(DAMAGE)

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation == "golem_melee":
		if animated_sprite.frame == attack_start_frame:
			attack_area_collision.monitoring = true
		elif animated_sprite.frame == attack_end_frame:
			attack_area_collision.monitoring = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "golem_melee" or animated_sprite.animation == "golem_projectile":
		attack_mode = false
