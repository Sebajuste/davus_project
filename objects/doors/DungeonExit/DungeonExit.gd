extends "res://objects/doors/Door.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use(actor) -> void:
	open()
	print("test")
	if opened:
		loading.change_scene("res://scenes/TestWorldGameplay/TestWorldGameplay.tscn")


func set_locked(value: bool) -> void:
	.set_locked(value)
	$Door1.locked = locked
	if locked:
		$OmniLight.light_color = Color.red
	else:
		$OmniLight.light_color = Color.green
