extends Node2D

@onready var protagonist: CharacterBody2D = $Protagonist
@onready var final_music: AudioStreamPlayer = $final_music
@onready var boss: CharacterBody2D = $boss
@onready var transitioner: PackedScene = preload("res://Scenes/transition_screen.tscn")
var next_level: PackedScene = preload("res://Scenes/end_screen.tscn")

var once = true
var transition_instance : CanvasLayer = null
var fade_out_speed = 0.1
var fade_in_speed = 1.5
var load_music = true
var reload = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if protagonist.get_death_status():
		boss.immobilize()
		final_music.volume_db = lerp(float(final_music.volume_db), float(-80), fade_out_speed * delta)
		if reload:
			reload = false	
			reset_level()
	if load_music:
		final_music.volume_db = lerp(float(final_music.volume_db), float(-10), fade_in_speed * delta)
		if final_music.volume_db == -10:
			load_music = false
	
	
	if boss.status() and once:
		once = false
		show_last_scene()
		
func show_last_scene():
	transition_instance = transitioner.instantiate()
	get_tree().root.add_child(transition_instance)
	await get_tree().create_timer(5.0).timeout
	transition_instance.transition()
	await transition_instance.transition_to_black
	get_tree().change_scene_to_packed(next_level)
	
	
func reset_level():
	transition_instance = transitioner.instantiate()
	get_tree().root.add_child(transition_instance)
	await get_tree().create_timer(2.0).timeout
	transition_instance.transition()
	await transition_instance.transition_to_black
	get_tree().reload_current_scene()
