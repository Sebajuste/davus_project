extends "res://tools/StreamingLevel/LayoutBatch.gd"

const Tentacle = preload("res://characters/Mobs/MobTentacle/MobTentacle.tscn")


func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	seed(str(loc).hash())
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if not _is_solid_tile(global_pos, noise, cap) and _is_solid_tile(global_pos+Vector3(0, -1, 0), noise, cap) and randi() % 4 == 1:
				var tentacle = Tentacle.instance()
				self.add_child(tentacle)
				tentacle.translate( Vector3(x*2, (size*2)-(y*2)-0.8, 0) )


func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap
