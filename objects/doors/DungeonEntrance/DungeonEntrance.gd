extends "res://objects/doors/Door.gd"



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


func use(actor) -> void:
	if open():
		return
	if opened:
		loading.load_scene("res://tileset/DungeonGenerator/Dungeon.tscn")


func set_locked(value: bool) -> void:
	.set_locked(value)
	if locked:
		$Entrance/DoorPanel/OmniLight.light_color = Color.red
	else:
		$Entrance/DoorPanel/OmniLight.light_color = Color.green
