extends CharacterBody2D

@onready var detection_area: Area2D = $detection_area
@onready var beam: PackedScene = preload("res://Scenes/laser_beam.tscn")
@onready var projectile: PackedScene = preload("res://Scenes/projectile.tscn")
@onready var attack_area_collision: Area2D = $AnimatedSprite2D/attack_area_collision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_timer: Timer = $dash_timer
@onready var cooldown_timer: Timer = $cooldown_timer

var SPEED = 30.00
var DAMAGE = 60.00
var detected = false
var direction = Vector2.ZERO
var target: Node2D = null
var attack_start_frame = 5
var attack_end_frame = 6
var attack_mode = false
var first_time = true
var y_offset = -50

var beam_instance: Node2D = null
var projectile_instance: Node2D = null

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
	attack_area_collision.scale = -abs(attack_area_collision.scale) if direction.x < 0 else abs(attack_area_collision.scale)
	
	#moveset logic from here
	if target and first_time: #first approach
		velocity = direction * SPEED
		move_and_slide()
		if global_position.distance_to(target.global_position)<210:
			first_time = false
			
	#moderate melee range position
	elif target and !attack_mode and 100 <= global_position.distance_to(target.global_position) and global_position.distance_to(target.global_position) < 200:
		animated_sprite.play("golem_idle")
		velocity = direction * SPEED
		move_and_slide()
	
	elif target and global_position.distance_to(target.global_position) < 100 and !attack_mode:
		velocity = Vector2.ZERO
		attack_protagonist()
	
	elif target and !attack_mode and cooldown_timer.time_left == 0:
		var move = randi() % 2
		print(move)
		if move == 1:
			perform_dash()
			velocity = direction * SPEED
			print(velocity)
			move_and_slide()
		elif move == 0:
			range_attack()
			
	elif target and global_position.distance_to(target.global_position) > 100: #default case
		velocity = direction * SPEED
		move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		target = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		
func attack_protagonist():
	animated_sprite.play("golem_melee")
	velocity = Vector2.ZERO
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
	if animated_sprite.animation == "golem_melee":
		attack_mode = false
	elif animated_sprite.animation == "golem_laser":
		attack_mode = false
		beam_instance = beam.instantiate()
		beam_instance.global_position = global_position + Vector2(0, y_offset)
		get_parent().add_child(beam_instance)
		beam_instance.set_landing_location(target.global_position)
		cooldown_timer.start()
		await get_tree().create_timer(1.2).timeout
		SPEED = 30.00
	elif animated_sprite.animation == "golem_projectile":
		attack_mode = false
		projectile_instance = projectile.instantiate()
		projectile_instance.global_position = global_position + Vector2(0, y_offset)
		get_parent().add_child(projectile_instance)
		projectile_instance.set_landing_location(target.global_position)
		cooldown_timer.start()
		SPEED = 30.00
	animated_sprite.play("golem_idle")

func perform_dash():
	animated_sprite.play("golem_dash")
	attack_mode= true 
	SPEED = 100.00
	dash_timer.start()
	
func _on_dash_timer_timeout() -> void:
	SPEED = 30.00
	velocity = Vector2.ZERO
	attack_mode = false
	cooldown_timer.start()

func range_attack():
	#var projectile_type = randi() % 2
	var projectile_type = 0
	if projectile_type == 1:
		animated_sprite.play("golem_laser")
	else:
		animated_sprite.play("golem_projectile")
	
	attack_mode = true
	SPEED = 0.00
