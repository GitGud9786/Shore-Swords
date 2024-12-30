extends Node2D

@onready var close_button: Button = $close_button
@onready var info_label: Label = $info_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.focus_mode = Control.FOCUS_NONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_label(message):
	info_label.text = message


func _on_close_button_pressed() -> void:
	queue_free()
