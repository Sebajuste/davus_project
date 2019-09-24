extends "res://objects/doors/Door.gd"

var dungeon_seed := randi()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$AnimationTree["parameters/playback"].start("closed")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func open() -> bool:
	if .open():
		$AnimationTree["parameters/playback"].travel("opened")
		return true
	return false


func close() -> bool:
	if .close():
		$AnimationTree["parameters/playback"].travel("closed")
		return true
	return false


func use(actor) -> bool:
	if open():
		return true
	if opened:
		var context = {
			"spawn_position": Vector3(self.global_transform.origin.x, self.global_transform.origin.y+2, 0),
			"dungeon_seed": dungeon_seed
		}
		loading.load_scene("res://scenes/Dungeon/Dungeon.tscn", context)
		return true
	return false


func set_locked(value: bool) -> void:
	.set_locked(value)
	if locked:
		$Entrance/DoorPanel/OmniLight.light_color = Color.red
	else:
		$Entrance/DoorPanel/OmniLight.light_color = Color.green
