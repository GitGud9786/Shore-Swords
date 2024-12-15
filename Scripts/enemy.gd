extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var detector_ray: RayCast2D = $detector_ray
@onready var detector_animation: AnimationPlayer = $detector_animation

const SPEED = 90.0

var lock_on=false
var HEALTH = 100
var DAMAGE = 20
var flash_color = Color(0.5,0,0)

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
	
	if detector_ray.is_colliding() and detector_ray.get_collider().get_node("protagonist_body_collision"):
		print("Protagonist hit")
		lock_on_protagonist(detector_ray.get_collider())
	else: #no longer hitting
		unlock_on_protagonist()


func _on_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)
	
func lock_on_protagonist(body) -> void:
	lock_on=true
	detector_animation.stop()
	var player_direction = global_position.direction_to(body.global_position)
	detector_ray.rotation = player_direction.angle()

func unlock_on_protagonist() -> void:
	print("No more detection")
	if lock_on:
		lock_on = false
		detector_animation.play("detection_animation")
