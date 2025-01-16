extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var detector_ray: RayCast2D = $detector_ray
@onready var detector_animation: AnimationPlayer = $detector_animation
@onready var attack_area_collision: Area2D = $AnimatedSprite2D/attack_area_collision

@onready var health_bar: ProgressBar = $health_bar
@onready var damage_bar: ProgressBar = $health_bar/damage_bar
@onready var damage_bar_timer: Timer = $health_bar/damage_bar_timer
@onready var body_collision: CollisionShape2D = $body_collision


var HEALTH = 100
var DAMAGE = 25
var SPEED = 90.0

var attack_mode = false
var lock_on=false
var flash_color = Color(0.5,0,0)
var protagonist_last_loc = Vector2.ZERO
var last_location_direction = Vector2.ZERO
var dead= false
var start_attack_frame = 3
var end_attack_frame = 5


func get_health():
	return HEALTH
	
func get_damage():
	return DAMAGE
	
func update_stats():
	DAMAGE *= 2
	SPEED *= 1.25
	animated_sprite.speed_scale = 1.25
	
func take_damage(damage):
	if body_collision.disabled:
		return
	HEALTH -= damage
	health_bar.visible = true
	update_health_bar(damage)
	if HEALTH<=0:
		body_collision.disabled = true
		dead=true
		attack_mode=false
		velocity = Vector2.ZERO
		animated_sprite.play("pawn_dead")
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
	health_bar.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if velocity != Vector2.ZERO and attack_mode==false and dead==false:
		animated_sprite.play("pawn_running")
		animated_sprite.flip_h = velocity.x < 0
		attack_area_collision.scale = -abs(attack_area_collision.scale) if velocity.x < 0 else abs(attack_area_collision.scale)
		
	elif dead==false and attack_mode==false:
		animated_sprite.play("pawn_idle")
	
	if dead==false and detector_ray.is_colliding() and detector_ray.get_collider().get_node("protagonist_body_collision") and attack_mode==false:
		protagonist_last_loc = detector_ray.get_collision_point()
		lock_on_protagonist(detector_ray.get_collider())
		animated_sprite.flip_h = detector_ray.get_collision_point().x < detector_ray.global_position.x
	elif dead==false and attack_mode==false: #no longer hitting
		unlock_on_protagonist()


func _on_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)
	
func lock_on_protagonist(body) -> void:
	detector_animation.playback_active = false
	var player_direction = global_position.direction_to(body.global_position)
	detector_ray.rotation = player_direction.angle()
	
	if global_position.distance_to(body.global_position)<40.0 and !body.get_death_status():
		attack_protagonist()
		
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
	attack_mode=true
	velocity = Vector2.ZERO
	animated_sprite.play("pawn_attack_1")


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "pawn_attack_1":
		animated_sprite.play("pawn_idle")
		attack_mode=false
		

func _on_attack_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		if(body.take_damage(DAMAGE)): #the player has died
			protagonist_last_loc = global_position
			detector_ray.enabled=false
			attack_mode=false
			animated_sprite.play("pawn_idle")


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation == "pawn_attack_1":
		if animated_sprite.frame == start_attack_frame:
			attack_area_collision.monitoring=true
		elif animated_sprite.frame == end_attack_frame:
			attack_area_collision.monitoring = false


func _on_damage_bar_timer_timeout() -> void:
	damage_bar.value = health_bar.value
