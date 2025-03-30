extends Node2D

@onready var level_3_music: AudioStreamPlayer = $level_3_music
@onready var reading_script: PackedScene = preload("res://Scenes/reading_script.tscn")
@onready var relic: Node2D = $relic
@onready var pickup_script_11: Node2D = $scripts/script1
@onready var protagonist: CharacterBody2D = $Protagonist
@onready var tnt_goblin: PackedScene = preload("res://Scenes/tnt_goblin.tscn")
@onready var archer: PackedScene = preload("res://Scenes/archer.tscn")
@onready var transitioner: PackedScene = preload("res://Scenes/transition_screen.tscn")
var next_level: PackedScene = preload("res://Level_Scripts/final_level.tscn")

var script_instance : Node2D = null
var enemies = 0
var spawn = true
var archer_positions = []
var tnt_goblin_positions = []
var transition_instance : CanvasLayer = null

var fade_in_speed = 1.5
var fade_out_speed = 0.1
var load_music = true
var reload = true

const str_11 = "With the relics I summon thee!"

var script_map = {
	"11": str_11
}

func create_read_script(read_script):
	if script_instance == null:
		script_instance = reading_script.instantiate()
		protagonist.add_child(script_instance)
		script_instance.global_position = protagonist.global_position
		script_instance.update_label(script_map[read_script])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	relic.choose_gold_type()
	pickup_script_11.set_count('11')
	
	
	var fire_goblin_node = get_node("Archer")
	for child in fire_goblin_node.get_children():
		enemies +=1
		archer_positions.append(child.global_position)
		
	var tnt_goblin_node = get_node("TNT goblins")
	for child in tnt_goblin_node.get_children():
		enemies +=1
		tnt_goblin_positions.append(child.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if protagonist.get_death_status():
		level_3_music.volume_db = lerp(float(level_3_music.volume_db), float(-80), fade_out_speed * delta)
		if reload:
			reload = false	
			reset_level()
	
	if load_music:
		level_3_music.volume_db = lerp(float(level_3_music.volume_db), float(-10), fade_in_speed * delta)
		if level_3_music.volume_db == -10:
			load_music = false
	
	
	if relic!=null and enemies==0: #spawn relic after all killed
		relic.get_node("relic_area_collision").monitoring = true
		relic.visible = true
	if relic==null and spawn:
		spawn = false
		for pos in archer_positions:
			var new_enemy = archer.instantiate()
			new_enemy.global_position = pos 
			add_child(new_enemy)
			await get_tree().create_timer(0.1).timeout
			new_enemy.update_stats()
		for pos in tnt_goblin_positions:
			var new_enemy = tnt_goblin.instantiate()
			new_enemy.global_position = pos 
			add_child(new_enemy)
			await get_tree().create_timer(0.1).timeout
			new_enemy.update_stats()

func kill_counter():
	enemies -= 1

func _on_tnt_goblins_child_exiting_tree(node: Node) -> void:
	if node.has_method("take_damage"):
		kill_counter()


func _on_archer_child_exiting_tree(node: Node) -> void:
	if node.has_method("take_damage"):
		kill_counter()

func _on_level_pass_area_body_entered(body: Node2D) -> void:
	if relic == null: #relic is collected
		if body.get_node("protagonist_body_collision"):
			body.input_disable()
			transition_instance = transitioner.instantiate()
			get_tree().root.add_child(transition_instance)
			await get_tree().create_timer(0.1).timeout
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
