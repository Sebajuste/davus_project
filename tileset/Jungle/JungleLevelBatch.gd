extends "res://tileset/LevelBatch.gd"


const TILES_RESOURCES := { 
	0x00:
		[ # Full
			preload("res://models/World/Jungle/Tiles/tile00.glb"),
		],
	0x01: 
		[ # Top empty
			preload("res://models/World/Jungle/Tiles/Tile01.glb"),
			preload("res://models/World/Jungle/Tiles/tile01.001.glb"),
		],
	0x02: 
		[ # Right empty
			preload("res://models/World/Jungle/Tiles/Tile02.glb"),
			preload("res://models/World/Jungle/Tiles/tile02.001.glb"),
		],
	0x03: 
		[ # Top Right empty
			preload("res://models/World/Jungle/Tiles/Tile03.glb"),
			preload("res://models/World/Jungle/Tiles/tile03.001.glb"),
		],
	0x04: 
		[ # Bottom empty
			preload("res://models/World/Jungle/Tiles/Tile04.glb"),
			preload("res://models/World/Jungle/Tiles/tile04.001.glb"),
		],
	0x05: 
		[ # Top Bottom empty
			preload("res://models/World/Jungle/Tiles/Tile05.glb"),
			preload("res://models/World/Jungle/Tiles/tile05.001.glb"),
		],
	0x06: 
		[ # Right Bottom empty
			preload("res://models/World/Jungle/Tiles/Tile06.glb"),
			preload("res://models/World/Jungle/Tiles/tile06.001.glb"),
		],
	0x07: 
		[ # Top Right Bottom empty
			preload("res://models/World/Jungle/Tiles/Tile07.glb"),
			preload("res://models/World/Jungle/Tiles/tile07.001.glb"),
		],
	0x08: 
		[ # Left empty
			preload("res://models/World/Jungle/Tiles/Tile08.glb"),
			preload("res://models/World/Jungle/Tiles/tile08.001.glb"),
		],
	0x09: 
		[ # Top Left empty
			preload("res://models/World/Jungle/Tiles/Tile09.glb"),
			preload("res://models/World/Jungle/Tiles/tile09.001.glb"),
		],
	0x0A: 
		[ # Right Left empty
			preload("res://models/World/Jungle/Tiles/Tile10.glb"),
			preload("res://models/World/Jungle/Tiles/tile10.001.glb"),
		],
	0x0B: 
		[ # Top Right Left empty
			preload("res://models/World/Jungle/Tiles/Tile11.glb"),
			preload("res://models/World/Jungle/Tiles/tile11.001.glb"),
		],
	0x0C: 
		[ # Bottom Left empty
			preload("res://models/World/Jungle/Tiles/Tile12.glb"),
			preload("res://models/World/Jungle/Tiles/tile12.001.glb"),
		],
	0x0D: 
		[ # Top Bottom Left empty
			preload("res://models/World/Jungle/Tiles/Tile13.glb"),
			preload("res://models/World/Jungle/Tiles/tile13.001.glb"),
		],
	0x0E: 
		[ # Right Bottom Left empty
			preload("res://models/World/Jungle/Tiles/Tile14.glb"),
			preload("res://models/World/Jungle/Tiles/tile14.001.glb"),
		],
	0x0F: 
		[ # Top Right Bottom Left empty
			preload("res://models/World/Jungle/Tiles/Tile15.glb"),
			preload("res://models/World/Jungle/Tiles/tile15.001.glb"),
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
	var tilesCategory = TILES_RESOURCES.get(mask)
	var variant = randi() % tilesCategory.size()
	return tilesCategory[variant].instance()
