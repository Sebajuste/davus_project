extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_health_changed(value, max_value):
	
	$Life/ProgressBar.max_value = max_value
	
	$Life/ProgressBar/Tween.interpolate_property(
		$Life/ProgressBar, "value",
		$Life/ProgressBar.value, value, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	
	$Life/ProgressBar/Tween.start()
	
