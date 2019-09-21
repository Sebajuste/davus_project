extends "res://objects/doors/Door.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use(actor) -> void:
	open()
	if opened:
		loading.change_scene("res://tileset/DungeonGenerator/Dungeon.tscn")


func set_locked(value: bool) -> void:
	.set_locked(value)
	if locked:
		$Entrance/DoorPanel/OmniLight.light_color = Color.red
	else:
		$Entrance/DoorPanel/OmniLight.light_color = Color.green