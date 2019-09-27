extends Spatial

export var key_floor_distance:float = 0#.25

func _ready():
	pass


func get_key_spot(rnd:RandomNumberGenerator) -> Vector3:
	var spots:Array = $Spots.get_children()
	var variant:int = rnd.randi() % spots.size()
	var spot:Position3D = spots[variant]
	return spot.global_transform.origin + Vector3(0, key_floor_distance, 0)

func populate_platforms(rnd:RandomNumberGenerator, resources:Array):
	var spots:Array = $Spots.get_children()
	for spot in spots:
		var pos:Vector3 = spot.translation
		var variant:int = rnd.randi() % resources.size()
		var platform = resources[variant].instance()
		platform.translate(pos)
		$Platforms.add_child(platform)