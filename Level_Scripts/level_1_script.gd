extends Node2D

@onready var reading_script: PackedScene = preload("res://Scenes/reading_script.tscn")
@onready var pickup_script_11: Node2D = $"Pickup Script/pickup_script_11"
@onready var pickup_script_12: Node2D = $"Pickup Script/pickup_script_12"
@onready var pickup_script_13: Node2D = $"Pickup Script/pickup_script_13"
@onready var pickup_script_14: Node2D = $"Pickup Script/pickup_script_14"
@onready var protagonist: CharacterBody2D = $Protagonist
@onready var pickup_script_15: Node2D = $"Pickup Script/pickup_script_15"
@onready var pickup_script_16: Node2D = $"Pickup Script/pickup_script_16"

@onready var health_bar: ProgressBar = $Protagonist/health_bar


var script_instance : Node2D = null

const str_11 = "SPACE to attack"
const str_12 = "Pawns are melee attackers"
const str_13 = "Meat restores health"
const str_14 = "Execute all foes"
const str_15 = "The relic respawns enemies"
const str_16 = "Head back to the start"
var script_map = {
	"11": str_11,
	"12": str_12,
	"13": str_13,
	"14": str_14,
	"15": str_15,
	"16": str_16
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pickup_script_11.set_count("11") #SPACE to attack
	pickup_script_12.set_count("12") #Pawns are melee attackers
	pickup_script_13.set_count("13") #Meat restores health
	pickup_script_14.set_count("14") #Execute all of them
	pickup_script_15.set_count("15") #The relic respawns enemies
	pickup_script_16.set_count("16") #Head back to the start
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_read_script(read_script):
	if script_instance == null:
		script_instance = reading_script.instantiate()
		protagonist.add_child(script_instance)
		script_instance.global_position = protagonist.global_position
		script_instance.update_label(script_map[read_script])
