extends Control

@onready var start_button: Button = $VBoxContainer/start_button
@onready var quit_button: Button = $VBoxContainer/quit_button
@onready var level_loader: PackedScene = preload("res://Scenes/Game.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.focus_mode = Control.FOCUS_NONE
	quit_button.focus_mode = Control.FOCUS_NONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_quit_button_pressed() -> void:
	pass


func _on_start_button_pressed() -> void:
	pass


func _on_start_button_button_up() -> void:
	print("GAME STARTED")
	get_tree().change_scene_to_packed(level_loader)


func _on_quit_button_button_up() -> void:
	get_tree().quit()
