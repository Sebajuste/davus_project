extends Spatial

export var door_id := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	print("test")
	if body.is_in_group("player") and body.has_method("give_object"):
		var item = {
			"type": "key"
		}
		body.give_object(item)
		queue_free()
	
	
