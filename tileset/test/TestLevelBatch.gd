extends "res://tileset/LevelBatch.gd"

const Tile = preload("Test.tscn")

func gen(loc: Vector3):
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if _is_solid_tile(global_pos):
				var tile = Tile.instance()
				self.add_child(tile)
				tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _create_bitmask(pos: Vector3) -> int:
	
	var mask = 0x00
	var index = 0
	
	for i in range(1, -2, -2):
		# Top / Bottom
		if noise.get_noise_2d(pos.x, pos.y + i) > cap:
			mask |= 0x01 << index
		
		# Left / Right
		if noise.get_noise_2d(pos.x + i, pos.y) > cap:
			mask |= 0x02 << index
			
		index += 2
		
	return mask
