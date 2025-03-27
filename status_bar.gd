extends ProgressBar

@onready var status_label: Label = $status_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_label(message):
	status_label.text = message
	
func ready_bar(time):
	max_value = time
	value = time
	min_value = 0
	
func update_bar(left):
	value = left
