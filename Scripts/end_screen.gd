extends Control

@onready var play_again: Button = $play_again
@onready var exit_button: Button = $exit_button
@onready var level_loader: PackedScene = preload("res://Scenes/Game.tscn")
@onready var transitioner: PackedScene = preload("res://Scenes/transition_screen.tscn")
@onready var end_music: AudioStreamPlayer = $end_music

var transition_instance : CanvasLayer = null


var fade_in_speed = 1.0
var load_music = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_again.focus_mode = Control.FOCUS_NONE
	exit_button.focus_mode = Control.FOCUS_NONE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if load_music:
		end_music.volume_db = lerp(float(end_music.volume_db), float(-10), fade_in_speed * delta)
		if end_music.volume_db == -10:
			load_music = false


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_again_pressed() -> void:
	transition_instance = transitioner.instantiate()
	get_tree().root.add_child(transition_instance)
	await get_tree().create_timer(0.1).timeout
	transition_instance.transition()
	await transition_instance.transition_to_black
	get_tree().change_scene_to_packed(level_loader)
