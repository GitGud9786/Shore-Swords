extends Node2D

@onready var reading_script: PackedScene = preload("res://Scenes/reading_script.tscn")
@onready var transitioner: PackedScene = preload("res://Scenes/transition_screen.tscn")
@onready var enemy: PackedScene = preload("res://Scenes/enemy.tscn")
var next_level: PackedScene = preload("res://Level_Scripts/level_2.tscn")
@onready var pickup_script_11: Node2D = $"Pickup Script/pickup_script_11"
@onready var pickup_script_12: Node2D = $"Pickup Script/pickup_script_12"
@onready var pickup_script_13: Node2D = $"Pickup Script/pickup_script_13"
@onready var pickup_script_14: Node2D = $"Pickup Script/pickup_script_14"
@onready var protagonist: CharacterBody2D = $Protagonist
@onready var pickup_script_15: Node2D = $"Pickup Script/pickup_script_15"
@onready var pickup_script_16: Node2D = $"Pickup Script/pickup_script_16"
@onready var relic: Node2D = $relic
@onready var pickup_script_17: Node2D = $"Pickup Script/pickup_script_17"

@onready var health_bar: ProgressBar = $Protagonist/health_bar

var foe_positions = []
var spawn = true
var script_instance : Node2D = null
var transition_instance : CanvasLayer = null
var enemies = 0

const str_11 = "SPACE to attack"
const str_12 = "Pawns are melee attackers"
const str_13 = "Meat restores health"
const str_14 = "Execute all foes for the RELIC"
const str_15 = "The relic respawns enemies"
const str_16 = "Head back to the start"
const str_17 = "They will be more aggressive"
var script_map = {
	"11": str_11,
	"12": str_12,
	"13": str_13,
	"14": str_14,
	"15": str_15,
	"16": str_16,
	"17": str_17
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pickup_script_11.set_count("11") #SPACE to attack
	pickup_script_12.set_count("12") #Pawns are melee attackers
	pickup_script_13.set_count("13") #Meat restores health
	pickup_script_14.set_count("14") #Execute all of them
	pickup_script_15.set_count("15") #The relic respawns enemies
	pickup_script_16.set_count("16") #Head back to the start
	pickup_script_17.set_count("17")
	relic.choose_bronze_type()
	var enemy_node = get_node("Enemy")
	for child in enemy_node.get_children():
		enemies +=1
		foe_positions.append(child.global_position)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if relic!=null and enemies==0: #spawn relic after all killed
		relic.get_node("relic_area_collision").monitoring = true
		relic.visible = true
	if relic==null and spawn:
		spawn = false
		for pos in foe_positions:
			var new_enemy = enemy.instantiate()
			new_enemy.global_position = pos 
			add_child(new_enemy)
			await get_tree().create_timer(0.1).timeout
			new_enemy.update_stats()
			print("Enemy added")
	
func create_read_script(read_script):
	if script_instance == null:
		script_instance = reading_script.instantiate()
		protagonist.add_child(script_instance)
		script_instance.global_position = protagonist.global_position
		script_instance.update_label(script_map[read_script])
		
func kill_counter():
	enemies -= 1

func _on_enemy_child_exiting_tree(node: Node) -> void:
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
			
