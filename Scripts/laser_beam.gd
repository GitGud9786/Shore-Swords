extends CharacterBody2D

var DAMAGE = 100.0
var landing_location = Vector2.ZERO
var direction = Vector2.ZERO

func set_landing_location(vector):
	landing_location = vector
	direction = global_position.direction_to(landing_location)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation = direction.angle()


func _on_attack_area_collision_body_entered(body: Node2D) -> void:
	if body.get_node("protagonist_body_collision"):
		body.take_damage(DAMAGE)


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
