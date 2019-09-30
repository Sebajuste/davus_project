extends "res://objects/doors/Door.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$AnimationTree["parameters/playback"].start("closed")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func open() -> bool:
	if .open():
		$OpenSound.play()
		$AnimationTree["parameters/playback"].travel("opened")
		return true
	return false


func close() -> bool:
	if .close():
		$AnimationTree["parameters/playback"].travel("closed")
		return true
	return false


func set_locked(value: bool) -> void:
	.set_locked(value)
	if locked:
		$OmniLight.light_color = Color.red
	else:
		$OmniLight.light_color = Color.green
