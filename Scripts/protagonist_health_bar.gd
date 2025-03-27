extends ProgressBar

@onready var damage_timer: Timer = $damage_bar/damage_timer
@onready var damage_bar: ProgressBar = $damage_bar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func update_damaged_health(damage):
	value -= damage
	damage_timer.start()
	
func update_regen_health(health):
	value += health
	damage_bar.value += health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_damage_timer_timeout() -> void:
	damage_bar.value = value

func ready_bar(HEALTH):
	value = HEALTH
	max_value = HEALTH
	min_value = 0
	damage_bar.value = HEALTH
	damage_bar.max_value = HEALTH
	damage_bar.min_value = 0
