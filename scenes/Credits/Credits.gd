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

func _input(event):
	if visible:
		if event is InputEventJoypadButton or event is InputEventKey:
			stop()


func start() -> void:
	if not visible:
		visible = true
		$AnimationPlayer.play("default")


func stop():
	visible = false
	$AnimationPlayer.stop()
