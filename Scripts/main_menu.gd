extends Control

@onready var start_button: Button = $VBoxContainer/start_button
@onready var quit_button: Button = $VBoxContainer/quit_button
@onready var level_loader: PackedScene = preload("res://Scenes/Game.tscn")
var next_level: PackedScene = preload("res://Level_Scripts/level_2.tscn")
@onready var transitioner: PackedScene = preload("res://Scenes/transition_screen.tscn")
@onready var main_menu_music: AudioStreamPlayer = $main_menu_music

var transition_instance : CanvasLayer = null
var fade_out = false
var fade_speed = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.focus_mode = Control.FOCUS_NONE
	quit_button.focus_mode = Control.FOCUS_NONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade_out:
		main_menu_music.volume_db = lerp(float(main_menu_music.volume_db), float(-80), fade_speed * delta)

func _on_quit_button_pressed() -> void:
	pass


func _on_start_button_pressed() -> void:
	pass


func _on_start_button_button_up() -> void:
	fade_out=true
	transition_instance = transitioner.instantiate()
	get_tree().root.add_child(transition_instance)
	await get_tree().create_timer(0.1).timeout
	transition_instance.transition()
	await transition_instance.transition_to_black
	get_tree().change_scene_to_packed(level_loader)


func _on_quit_button_button_up() -> void:
	get_tree().quit()
