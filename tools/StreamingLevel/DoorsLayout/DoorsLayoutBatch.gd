extends "res://tools/StreamingLevel/LayoutBatch.gd"

const DungeonEntrance = preload("res://objects/doors/DungeonEntrance/DungeonEntrance.tscn")

var top_max_y : int
var top_max_value : float
var end_max_y : int

func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	
	var position_random := RandomNumberGenerator.new()
	position_random.seed = str(loc).hash()
	
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if global_pos.y < end_max_y and _is_solid_tile(global_pos, noise, cap) and not _is_solid_tile(global_pos+Vector3(0, 1, 0), noise, cap) and position_random.randi() % 32 == 1:
				var local_pos = Vector3(x*2, (size*2)-(y*2), -2)
				var dungeon_entrance = DungeonEntrance.instance()
				dungeon_entrance.locked = true
				dungeon_entrance.translate( local_pos )
				dungeon_entrance.id = str(global_pos+local_pos).hash()
				self.add_child(dungeon_entrance)
				emit_signal("object_emited", dungeon_entrance)


func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap
