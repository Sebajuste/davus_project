extends "res://tileset/LevelBatch.gd"


const TILES_RESOURCES := { 
	0x00:
		[ # Full
			preload("res://models/Tiles/tilePlain.glb"),
		],
	0x01:
		[
			preload("res://models/Tiles/tileFloor.glb"),
		],
	0x02:
		[
			preload("res://models/Tiles/tileRoof.glb"),
		],
	}


func gen(loc: Vector3):
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if _is_solid_tile(global_pos):
				var mask = _create_bitmask( global_pos )
				var tile = _create_tile(mask)
				if tile:
					self.add_child(tile)
					tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _create_bitmask(global_pos: Vector3) -> int:
	
	var mask = 0x00
	var index = 0
	
	for i in range(1, -2, -2):
		# Top / Bottom
		var top_bottom_global_pos = global_pos + Vector3(0, i, 0)
		if not _is_solid_tile(top_bottom_global_pos):
			mask |= 0x01 << index
		
		# Left / Right
		var left_right_global_pos = global_pos + Vector3(i, 0, 0)
		if not _is_solid_tile(left_right_global_pos):
			mask |= 0x02 << index
			
		index += 2
		
	return mask


func _create_tile(mask: int) -> Node:
	
	var tilesCategory = {}
	if mask & 0x01:
		tilesCategory = TILES_RESOURCES.get(0x01)
	elif mask & 0x04:
		tilesCategory = TILES_RESOURCES.get(0x02)
	elif mask == 0:
		tilesCategory = TILES_RESOURCES.get(0x00)
		
	if tilesCategory:
		var variant = randi() % tilesCategory.size()
		return tilesCategory[variant].instance()
	
	return null