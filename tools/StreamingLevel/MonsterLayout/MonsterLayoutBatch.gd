extends "res://tools/StreamingLevel/LayoutBatch.gd"

const Tentacle = preload("res://characters/Mobs/MobTentacle/MobTentacle.tscn")
const Fly = preload("res://characters/Mobs/Fly/Fly.tscn")

var top_max_y : int
var top_max_value : float
var end_max_y : int

func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	seed(str(loc).hash())
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if global_pos.y < end_max_y and not _is_solid_tile(global_pos, noise, cap) and _is_solid_tile(global_pos+Vector3(0, -1, 0), noise, cap) and randi() % 8 == 1:
				
				if randi() % 10 == 1:
					var fly = Fly.instance()
					self.add_child(fly)
					fly.translate( Vector3(x*2, (size*2)-(y*2), 0) )
				else:
					var tentacle = Tentacle.instance()
					self.add_child(tentacle)
					tentacle.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap
