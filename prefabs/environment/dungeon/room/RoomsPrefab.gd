extends Spatial

export var key_floor_distance:float = 0#.25

var _spots:Array
var rack

func _ready():
	_spots = $Spots.get_children()


func get_spot(rnd:RandomNumberGenerator) -> Vector3:
	if _spots.size() == 0:
		_spots = $Spots.get_children()
		print("Not enought spots in prefab, overlap accepted")
	
	var variant:int = rnd.randi() % _spots.size()
	var spot:Position3D = _spots[variant]
	_spots.erase(spot)
	return spot.global_transform.origin + Vector3(0, key_floor_distance, 0)


func populate_platforms(rnd:RandomNumberGenerator, resources:Array):
	var spots:Array = $Spots.get_children()
	for spot in spots:
		var pos:Vector3 = spot.translation
		var variant:int = rnd.randi() % resources.size()
		var platform = resources[variant].instance()
		platform.translate(pos)
		$Platforms.add_child(platform)