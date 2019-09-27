extends "res://objects/doors/Door.gd"

var spawn_position: Vector3

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


func use(actor) -> bool:
	if .use(actor):
		return false
	if opened:
		var context = {
			"player_position": spawn_position
		}
		loading.load_scene("res://scenes/WorldPlanet/WorldPlanet.tscn", context)
		return true
	return false


func set_locked(value: bool) -> void:
	.set_locked(value)
	if locked:
		$OmniLight.light_color = Color.red
	else:
		$OmniLight.light_color = Color.green

