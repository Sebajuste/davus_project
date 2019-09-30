extends "res://tools/StreamingLevel/LayoutBatch.gd"

const DoorKey = preload("res://objects/keys/DoorKey/DoorKey.tscn")

var top_max_y : int
var top_max_value : float
var end_max_y : int

var drop_rate: float

func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	pass
	
	seed(str(loc).hash())
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if global_pos.y < end_max_y and not _is_solid_tile(global_pos, noise, cap) and _is_solid_tile(global_pos+Vector3(0, -1, 0), noise, cap) and randf() <= drop_rate:
				
				var door_key = DoorKey.instance()
				self.add_child(door_key)
				door_key.translate( Vector3(x*2, (size*2)-(y*2), 0) )
				
				pass
	


func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap
