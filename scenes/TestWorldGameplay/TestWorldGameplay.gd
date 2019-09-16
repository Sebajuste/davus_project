extends Spatial



# Called when the node enters the scene tree for the first time.
func _ready():
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	
