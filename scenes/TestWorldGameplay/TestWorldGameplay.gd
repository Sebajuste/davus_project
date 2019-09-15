extends Spatial



# Called when the node enters the scene tree for the first time.
func _ready():
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	
