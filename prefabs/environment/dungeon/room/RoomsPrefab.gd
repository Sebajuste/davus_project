extends Spatial

func _ready():
	pass


func get_key_spot(rnd:RandomNumberGenerator) -> Vector3:
	var spots:Array = $KeySpots.get_children()
	var variant:int = rnd.randi() % spots.size()
	var spot:Position3D = spots[variant]
	return spot.global_transform.origin