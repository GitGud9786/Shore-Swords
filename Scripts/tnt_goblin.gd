extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var detector_ray: RayCast2D = $detector_ray
@onready var detector_animation: AnimationPlayer = $detector_animation
@onready var tnt: PackedScene = preload("res://Scenes/tnt.tscn")

@onready var health_bar: ProgressBar = $health_bar
@onready var damage_bar: ProgressBar = $health_bar/damage_bar
@onready var damage_bar_timer: Timer = $health_bar/damage_bar_timer


const SPEED = 80.0

var HEALTH = 100
var DAMAGE = 40
var dead = false
var attack_mode = false
var lock_on=false
var flash_color = Color(0.5,0,0)
var protagonist_last_loc = Vector2.ZERO
var last_location_direction = Vector2.ZERO
var throw_frame = 2
var can_attack = true

var tnt_instance : Node2D = null

func get_health():
	return HEALTH
	
func get_damage():
	return DAMAGE

func take_damage(damage):
	HEALTH -= damage
	update_health_bar(damage)
	if HEALTH<=0:
		dead=true
		attack_mode=false
		velocity = Vector2.ZERO
		print("Pawn killed")
		animated_sprite.play("tnt_dead")
		await get_tree().create_timer(1.4).timeout
		queue_free()
	else:#only show a hit effect
		animated_sprite.modulate = flash_color
		timer.start()

func update_health_bar(damage):
	health_bar.value -= damage
	if health_bar.value<=0:
		health_bar.queue_free()
	damage_bar_timer.start()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = HEALTH
	health_bar.value = HEALTH
	damage_bar.max_value = HEALTH
	damage_bar.value = HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if velocity != Vector2.ZERO and attack_mode==false and dead==false:
		animated_sprite.play("tnt_running")
		animated_sprite.flip_h = velocity.x < 0
		
	elif dead==false and attack_mode==false:
		animated_sprite.play("tnt_idle")
		
	if detector_ray.is_colliding() and detector_ray.get_collider().get_node("protagonist_body_collision") and dead==false and attack_mode==false:
		protagonist_last_loc = detector_ray.get_collision_point()
		lock_on_protagonist(detector_ray.get_collider())
		animated_sprite.flip_h = detector_ray.get_collision_point().x < detector_ray.global_position.x
	elif dead==false and attack_mode==false: #no longer hitting
		unlock_on_protagonist()

func lock_on_protagonist(body) -> void: 
	detector_animation.playback_active = false
	var player_direction = global_position.direction_to(body.global_position)
	detector_ray.rotation = player_direction.angle()
	if global_position.distance_to(body.global_position)<200.0 and !body.get_death_status() and can_attack:
		can_attack=false
		attack_protagonist()
		
	elif not can_attack:
		velocity=Vector2.ZERO
		animated_sprite.play("tnt_idle")
		
	elif !body.get_death_status():
		lock_on=true
		attack_mode=false
		velocity = SPEED * player_direction
		move_and_slide()
	

func unlock_on_protagonist() -> void:
	if lock_on:
		lock_on = false
	detector_animation.playback_active = true
	if protagonist_last_loc != Vector2.ZERO:
		if global_position.distance_to(protagonist_last_loc)<1.0:#reached location
			velocity = Vector2.ZERO
		else:
			last_location_direction = global_position.direction_to(protagonist_last_loc)
			velocity = last_location_direction * SPEED
			move_and_slide()
	
func attack_protagonist() -> void:
	attack_mode = true
	velocity = Vector2.ZERO
	animated_sprite.play("tnt_attacking")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "tnt_attacking":
		animated_sprite.play("tnt_idle")
		attack_mode=false
		await get_tree().create_timer(1.5).timeout
		can_attack=true


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation=="tnt_attacking":
		if animated_sprite.frame == throw_frame:
			tnt_instance = tnt.instantiate()
			tnt_instance.global_position = global_position
			get_parent().add_child(tnt_instance)
			tnt_instance.set_landing_location(protagonist_last_loc)


func _on_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)
