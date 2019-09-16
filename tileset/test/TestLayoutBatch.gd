extends "res://tools/StreamingLevel/LayoutBatch.gd"

const Tile = preload("Test.tscn")

func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if _is_solid_tile(global_pos, noise, cap):
				var tile = Tile.instance()
				self.add_child(tile)
				tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap
