extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal transition_to_black

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.visible = false

func transition():
	color_rect.visible = true
	animation_player.play("fade_to_black")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_normal":
		color_rect.visible = false
		queue_free()
	elif anim_name == "fade_to_black":
		emit_signal("transition_to_black")
		animation_player.play("fade_to_normal")
