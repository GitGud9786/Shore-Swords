extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_collision: Area2D = $AnimatedSprite2D/area_collision
@onready var timer: Timer = $Timer
@onready var death_timer: Timer = $death_timer
@onready var referred_health_bar: PackedScene = preload("res://Scenes/protagonist_health_bar.tscn")
@onready var protagonist_body_collision: CollisionShape2D = $protagonist_body_collision
@onready var incendiery_timer: Timer = $incendiery_timer
@onready var shrapnel_timer: Timer = $shrapnel_timer
@onready var status_bar: PackedScene = preload("res://Scenes/status_bar.tscn")
@onready var box_container: VBoxContainer = $box_container

var input_enabled = 1
var flash_color = Color(0.5,0,0)
var dead=false
var start_attack_frame = 3
var end_attack_frame = 5
var heavy_attack_frame = 7
var heavy_attack_end_frame = 9
var can_interact = false
var attack_type : int #1 for light, 2 for heavy

var burning_effect = false
var shrapnel_effect = false
var can_burn = true
var can_shrapnel = true

var HEALTH = 300.00
var MAX_HEALTH = 300.00
var SPEED = 125.0 
var DAMAGE= 40.0 * 5

var health_bar_offset = Vector2(220,-250)
var read_script =""
var health_instance : ProgressBar = null
var incendiary_bar_instance : ProgressBar = null
var shrapnel_bar_instance : ProgressBar = null
var passed = false
var damage_thrice = false

func update_level_1():
	SPEED = SPEED * 1.5
	
func update_level_2():
	DAMAGE = DAMAGE * 3

func update_level_3():
	damage_thrice = true

func invincible():
	passed = true

func input_disable():
	input_enabled = 0
	velocity = Vector2.ZERO
	animated_sprite.play("knight_idle")
	protagonist_body_collision.disabled = true

func enable_burn():
	if can_burn:
		burning_effect = true
		incendiary_bar_instance = status_bar.instantiate()
		box_container.add_child(incendiary_bar_instance)
		incendiary_bar_instance.update_label("Burning")
		incendiary_bar_instance.ready_bar(8)
		incendiery_timer.start()
		can_burn = false
	
func enable_shrapnel():
	if can_shrapnel:
		shrapnel_effect = true
		shrapnel_bar_instance = status_bar.instantiate()
		box_container.add_child(shrapnel_bar_instance)
		shrapnel_bar_instance.update_label("Shrapnel")
		shrapnel_bar_instance.ready_bar(15)
		shrapnel_timer.start()
		can_shrapnel = false
	
func _ready() -> void:
	box_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	health_instance = referred_health_bar.instantiate()
	add_child(health_instance)
	health_instance.ready_bar(HEALTH)
	health_instance.global_position = global_position + health_bar_offset

func _physics_process(delta: float) -> void:
	if burning_effect and not dead:
		take_damage(0.1)
		incendiary_bar_instance.update_bar(incendiery_timer.time_left)
	if shrapnel_effect and not dead:
		shrapnel_bar_instance.update_bar(shrapnel_timer.time_left)
		take_damage(0.05)

	var x_direction := Input.get_axis("move_left", "move_right")
	var y_direction := Input.get_axis("move_up", "move_down")
	
	if can_interact and Input.is_action_just_pressed("interact") and input_enabled: #found a script
		get_parent().create_read_script(read_script)
	
	if Input.is_action_just_pressed("attack") and !dead and input_enabled:#initiate attack
		input_enabled= 0
		attack_type = 1
		animated_sprite.play("knight_attack_1")
		
	if Input.is_action_just_pressed("heavy_attack") and !dead and input_enabled:#initiate attack
		input_enabled= 0
		attack_type = 2
		animated_sprite.play("knight_heavy_attack")
	
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
	
	var velocity_x = x_direction * SPEED * input_enabled
	var velocity_y = y_direction * SPEED * input_enabled
	
	if velocity_x != 0 and velocity_y != 0:
		var velocity_length = sqrt(velocity_x * velocity_x + velocity_y * velocity_y)
		velocity_x = velocity_x / velocity_length * SPEED * input_enabled
		velocity_y = velocity_y / velocity_length * SPEED * input_enabled
	
	# Apply the velocity values to the character
	velocity.x = velocity_x
	velocity.y = velocity_y
	move_and_slide()

func regen_health(health):
	HEALTH = min(MAX_HEALTH, HEALTH + health)
	health_instance.update_regen_health(health)

func get_health():
	return HEALTH

func get_damage():
	return DAMAGE * attack_type	

func get_death_status():
	return dead

func take_damage(damage) -> bool:
	if damage_thrice:
		damage = damage/3
	if passed:
		return false
	HEALTH -= damage
	health_instance.update_damaged_health(damage)
	if HEALTH<=0:
		input_enabled = 0
		dead=true
		velocity = Vector2.ZERO
		animated_sprite.play("knight_dead")
		death_timer.start()
		return true
	else:#only show a hit effect
		animated_sprite.modulate = flash_color
		timer.start()
		return false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "knight_attack_1":
		input_enabled= 1
		animated_sprite.play("knight_idle")
	elif animated_sprite.animation == "knight_heavy_attack":
		input_enabled= 1
		animated_sprite.play("knight_idle")


func _on_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("body_collision"):
		body.take_damage(get_damage())

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation == "knight_attack_1":
		if animated_sprite.frame == start_attack_frame:
			area_collision.monitoring=true
		elif animated_sprite.frame == end_attack_frame:
			area_collision.monitoring=false
	elif animated_sprite.animation == "knight_heavy_attack":
		if animated_sprite.frame == heavy_attack_frame:
			area_collision.monitoring=true
		elif animated_sprite.frame == heavy_attack_end_frame:
			area_collision.monitoring=false

func _on_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)

func _on_button_checker_area_area_entered(area: Area2D) -> void:
	if area.name=="pickup_script_area":
			read_script = area.get_parent().get_count()
			can_interact = true

func _on_button_checker_area_area_exited(area: Area2D) -> void:
	if area.name=="pickup_script_area":
			can_interact = false


func _on_death_timer_timeout() -> void:
	pass


func _on_incendiery_timer_timeout() -> void:
	burning_effect=false
	can_burn = true
	incendiary_bar_instance.queue_free()


func _on_shrapnel_timer_timeout() -> void:
	shrapnel_effect=false
	can_shrapnel = true
	shrapnel_bar_instance.queue_free()
