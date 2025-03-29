extends Node2D

@onready var boss: CharacterBody2D = $boss
@onready var transitioner: PackedScene = preload("res://Scenes/transition_screen.tscn")
var next_level: PackedScene = preload("res://Scenes/end_screen.tscn")

var once = true
var transition_instance : CanvasLayer = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
