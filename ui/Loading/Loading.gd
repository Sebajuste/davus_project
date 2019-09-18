extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_value(value: int):
	$MarginContainer/ProgressBar.value = value


func set_progress(min_value, max_value, value):
	
	$MarginContainer/ProgressBar.min_value = min_value
	$MarginContainer/ProgressBar.max_value = max_value
	$MarginContainer/ProgressBar.value = value
	
