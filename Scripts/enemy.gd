extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

const SPEED = 100.0

var HEALTH = 100
var DAMAGE = 20
var flash_color = Color(0.9,0,0)
var flash_duration = 0.4

func get_health():
	return HEALTH
	
func get_damage():
	return DAMAGE
	
func take_damage(damage):
	HEALTH -= damage
	if HEALTH<=0:
		animated_sprite.play("pawn_dead")
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:#only show a hit effect
		animated_sprite.modulate = flash_color
		timer.start()
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#velocity.x = SPEED
	#move_and_slide()


func _on_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)
