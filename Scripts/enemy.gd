extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var detector_ray: RayCast2D = $detector_ray
@onready var detector_animation: AnimationPlayer = $detector_animation
@onready var attack_area_collision: Area2D = $AnimatedSprite2D/attack_area_collision


const SPEED = 90.0

var attack_mode = false
var lock_on=false
var HEALTH = 100
var DAMAGE = 20
var flash_color = Color(0.5,0,0)
var protagonist_last_loc = Vector2.ZERO
var last_location_direction = Vector2.ZERO

func get_health():
	return HEALTH
	
func get_damage():
	return DAMAGE
	
func take_damage(damage):
	HEALTH -= damage
	if HEALTH<=0:
		animated_sprite.play("pawn_dead")
		await get_tree().create_timer(1.4).timeout
		queue_free()
	else:#only show a hit effect
		animated_sprite.modulate = flash_color
		timer.start()
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if velocity != Vector2.ZERO and attack_mode==false:
		animated_sprite.play("pawn_running")
		animated_sprite.flip_h = velocity.x < 0
		attack_area_collision.scale = -abs(attack_area_collision.scale) if velocity.x < 0 else abs(attack_area_collision.scale)


	else:
		animated_sprite.play("pawn_idle")
	
	if detector_ray.is_colliding() and detector_ray.get_collider().get_node("protagonist_body_collision"):
		protagonist_last_loc = detector_ray.get_collision_point()
		lock_on_protagonist(detector_ray.get_collider())
	else: #no longer hitting
		unlock_on_protagonist()


func _on_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)
	
func lock_on_protagonist(body) -> void: #WORK NEXT HERE TO MAKE ENEMY ATTACK THE PROTAGONIST
	if global_position.distance_to(body.global_position)<50.0:
		attack_mode=true
		velocity = Vector2.ZERO
		print("Enemy attacking")
		animated_sprite.play("pawn_attack_1")
	else:
		lock_on=true
		attack_mode=false
		detector_animation.stop()
		var player_direction = global_position.direction_to(body.global_position)
		detector_ray.rotation = player_direction.angle()
		velocity = SPEED * player_direction
		move_and_slide()

func unlock_on_protagonist() -> void:
	if lock_on:
		lock_on = false
	detector_animation.play("detection_animation")
	if protagonist_last_loc != Vector2.ZERO:
		if global_position.distance_to(protagonist_last_loc)<1.0:#reached location
			velocity = Vector2.ZERO
		else:
			last_location_direction = global_position.direction_to(protagonist_last_loc)
			velocity = last_location_direction * SPEED
			move_and_slide()
		
