extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_collision: Area2D = $AnimatedSprite2D/area_collision
@onready var timer: Timer = $Timer

var input_enabled = 1
var HEALTH = 100
var flash_color = Color(0.5,0,0)
var dead=false
var start_attack_frame = 3
var end_attack_frame = 5

const SPEED = 120
const DAMAGE= 50
#const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x_direction := Input.get_axis("move_left", "move_right")
	var y_direction := Input.get_axis("move_up", "move_down")
	
	if Input.is_action_just_pressed("attack") and !dead:#initiate attack
		input_enabled= 0
		#area_collision.monitoring=true
		var attack_type = randi() % 2 + 1
		animated_sprite.play("knight_attack_"+str(attack_type))
	
	if x_direction>0 and input_enabled and !dead:#moving right
		animated_sprite.play("knight_running")
		animated_sprite.flip_h = false
		area_collision.scale = abs(area_collision.scale)
	elif x_direction<0 and input_enabled and !dead:#moving left
		animated_sprite.play("knight_running")
		animated_sprite.flip_h = true
		area_collision.scale = -abs(area_collision.scale)
	
	if y_direction!=0 and input_enabled and !dead:#moving up or down
		animated_sprite.play("knight_running")
	
	if x_direction==0 and y_direction==0 and input_enabled and !dead:#fully still
		animated_sprite.play("knight_idle")
	
	if x_direction and !dead:
		velocity.x = x_direction * SPEED * input_enabled
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if y_direction and !dead:
		velocity.y = y_direction * SPEED * input_enabled
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	#print(x_direction," ", y_direction," ",input_enabled)

func regen_health(health):
	HEALTH += 40
	print("Health: ", HEALTH)

func get_health():
	return HEALTH

func get_damage():
	return DAMAGE	

func get_death_status():
	return dead

func take_damage(damage) -> bool:
	HEALTH -= damage
	if HEALTH<=0:
		input_enabled = false
		dead=true
		velocity = Vector2.ZERO
		print("You died")
		animated_sprite.play("knight_dead")
		await get_tree().create_timer(1.4).timeout
		queue_free()
		return true
	else:#only show a hit effect
		animated_sprite.modulate = flash_color
		timer.start()
		return false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "knight_attack_1" or animated_sprite.animation == "knight_attack_2":
		input_enabled= 1
		animated_sprite.play("knight_idle")


func _on_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("body_collision"):
		print("Enemy hit successful")
		body.take_damage(20)
		print(body.get_health())


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation == "knight_attack_1" or animated_sprite.animation == "knight_attack_2":
		if animated_sprite.frame == start_attack_frame:
			area_collision.monitoring=true
		elif animated_sprite.frame == end_attack_frame:
			area_collision.monitoring=false


func _on_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)
