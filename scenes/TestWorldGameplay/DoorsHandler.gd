extends Node

const DOOR_KEY := preload("res://objects/keys/DoorKey/DoorKey.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DoorsLevelLayout_batch_generated(batch):
	
	for door in batch.get_children():
		
		var door_key := DOOR_KEY.instance()
		door_key.door_id = door.id
		
		# TODO : put key in world
		
		pass
	
	pass # Replace with function body.
