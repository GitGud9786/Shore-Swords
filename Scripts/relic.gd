extends Node2D
@onready var relic_area_collision: Area2D = $relic_area_collision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_relic_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		queue_free()
		
func choose_bronze_type():
	animated_sprite.animation = "bronze_relic"
	
func choose_silver_type():
	animated_sprite.animation = "silver_relic"
	
func choose_gold_type():
	animated_sprite.animation = "gold_relic"
