extends Node2D

@onready var reading_script: PackedScene = preload("res://Scenes/reading_script.tscn")
@onready var pickup_script_11: Node2D = $"Pickup Script/script1"
@onready var pickup_script_12: Node2D = $"Pickup Script/script2"
@onready var pickup_script_13: Node2D = $"Pickup Script/script3"
@onready var protagonist: CharacterBody2D = $Protagonist
@onready var relic: Node2D = $relic
@onready var fire_goblin: PackedScene = preload("res://Scenes/fire_goblin.tscn")
@onready var tnt_goblin: PackedScene = preload("res://Scenes/tnt_goblin.tscn")
@onready var level_pass_area: Area2D = $level_pass_area
@onready var transitioner: PackedScene = preload("res://Scenes/transition_screen.tscn")
var next_level: PackedScene = preload("res://Level_Scripts/level_3.tscn")

var fire_goblin_positions = []
var tnt_goblin_positions = []
var spawn = true
var script_instance : Node2D = null
var transition_instance : CanvasLayer = null
var enemies = 0

const str_11 = "Fiery goblins..."
const str_12 = "Beware of EXPLOSIVES!"
const str_13 = "BURN BURN BURN!"

var script_map = {
	"11": str_11,
	"12": str_12,
	"13": str_13
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pickup_script_11.set_count("11") #SPACE to attack
	pickup_script_12.set_count("12") #Pawns are melee attackers
	pickup_script_13.set_count("13") #Meat restores health
	relic.choose_silver_type()

	var fire_goblin_node = get_node("Fire Goblins")
	for child in fire_goblin_node.get_children():
		enemies +=1
		fire_goblin_positions.append(child.global_position)
		
	var tnt_goblin_node = get_node("TNT enemies")
	for child in tnt_goblin_node.get_children():
		enemies +=1
		tnt_goblin_positions.append(child.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if relic!=null and enemies==0: #spawn relic after all killed
		relic.get_node("relic_area_collision").monitoring = true
		relic.visible = true
	if relic==null and spawn:
		spawn = false
		for pos in fire_goblin_positions:
			var new_enemy = fire_goblin.instantiate()
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
	
func create_read_script(read_script):
	if script_instance == null:
		script_instance = reading_script.instantiate()
		protagonist.add_child(script_instance)
		script_instance.global_position = protagonist.global_position
		script_instance.update_label(script_map[read_script])
		
func kill_counter():
	enemies -= 1
	print(enemies)

func _on_tnt_enemies_child_exiting_tree(node: Node) -> void:
	if node.has_method("take_damage"):
		kill_counter()


func _on_fire_goblins_child_exiting_tree(node: Node) -> void:
	kill_counter()


func _on_level_pass_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if relic == null: #relic is collected
		if body.get_node("protagonist_body_collision"):
			body.input_disable()
			transition_instance = transitioner.instantiate()
			get_tree().root.add_child(transition_instance)
			await get_tree().create_timer(0.1).timeout
			transition_instance.transition()
			await transition_instance.transition_to_black
			get_tree().change_scene_to_packed(next_level)
