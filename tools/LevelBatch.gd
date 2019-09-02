extends Spatial

export var size := 16
export(float, -1.0, 1.0) var cap := 0.15
export var debug := true

var _noise

 # TODO : Complete the categories with the corresponding files.
const TILES_RESOURCES := { 
	0x01: 
		[ # Category 1 
	    	preload("res://models/World/Jungle/Tiles/Tile00.glb"),
	    	preload("res://models/World/Jungle/Tiles/Tile01.glb"),
		],
	0x02: 
		[ # Category 2
			preload("res://models/World/Jungle/Tiles/Tile00.glb"),
			preload("res://models/World/Jungle/Tiles/Tile01.glb"),
		],
	0x03: 
		[ # Category 3
			preload("res://models/World/Jungle/Tiles/Tile00.glb"),
			preload("res://models/World/Jungle/Tiles/Tile01.glb"),
		],
	0x04: 
		[ # Category 4
			preload("res://models/World/Jungle/Tiles/Tile00.glb"),
			preload("res://models/World/Jungle/Tiles/Tile01.glb"),
		],
	0x05: 
		[ # Category 5
			preload("res://models/World/Jungle/Tiles/Tile00.glb"),
			preload("res://models/World/Jungle/Tiles/Tile01.glb"),
		],
	}


func _ready():
	
	if debug:
		$ImmediateGeometry.begin(Mesh.PRIMITIVE_LINE_LOOP)
		
		$ImmediateGeometry.set_color(Color(1.0, 0.0, 0.0))
		
		$ImmediateGeometry.add_vertex(Vector3(0, 0, 1))
		$ImmediateGeometry.add_vertex(Vector3(size*2, 0, 1))
		$ImmediateGeometry.add_vertex(Vector3(size*2, size*2, 1))
		$ImmediateGeometry.add_vertex(Vector3(0, size*2, 1))
		
		$ImmediateGeometry.end()
	
	pass


func gen(loc: Vector3):
	
	for x in range(size):
		for y in range(size):
			var pos = Vector3(loc.x+x, loc.y-y, 0)
			var mask = 0
			if _is_solid_tile(pos.x, pos.y):
				mask = _create_bitmask( pos )
				var tile = _create_tile(mask)
				if tile:
					self.add_child(tile)
					tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _is_solid_tile(x: int, y: int):
	return _noise.get_noise_2d(x, y) > cap


func _create_bitmask(pos: Vector3) -> int:
	
	var mask = 0x00
	var index = 0
	
	for i in range(1, -2, -2):
		# Top / Bottom
		if not _is_solid_tile(pos.x, pos.y + i):
			mask |= 0x01 << index
		
		# Left / Right
		if not _is_solid_tile(pos.x + i, pos.y):
			mask |= 0x02 << index
			
		index += 2
		
	return mask


func _get_tile_variant(category: int, angle: float) -> Node:
	
	var tilesCategory = TILES_RESOURCES.get(category)
	var variant = randi() % tilesCategory.size()
	var tile = tilesCategory[variant].instance()
	
	if angle != 0:
		# TODO : Check compliance with the "Tile" name in the tiles files.
		tile.find_node("Tile").rotate_z(angle)
	
	return tile


func _create_tile(mask: int) -> Node:

	match mask:
		0x1:	# Top
			return _get_tile_variant(1, 0)
		0x2:	# Right
			return _get_tile_variant(1, PI * 0.5)
		0x3:	# Top Right
			return _get_tile_variant(2, 0)
		0x4:	# Bottom
			return _get_tile_variant(1, PI)
		0x5:	# Top Bottom
			return _get_tile_variant(5, 0)
		0x6:	# Right Bottom
			return _get_tile_variant(2, PI * 0.5)
		0x7:	# Top Right Bottom
			return _get_tile_variant(3, 0)
		0x8:	# Left
			return _get_tile_variant(1, PI * 1.5)
		0x9:	# Top Left
			return _get_tile_variant(2, PI * 1.5)
		0xA:	# Right Left
			return _get_tile_variant(5, PI * 0.5)
		0xB:	# Top Right Left
			return _get_tile_variant(3, PI * 1.5)
		0xC:	# Bottom Left
			return _get_tile_variant(2, PI)
		0xD:	# Top Bottom Left
			return _get_tile_variant(3, PI)
		0xE:	# Right Bottom Left
			return _get_tile_variant(3, PI * 0.5)
		0xF:	# Top Right Bottom Left
			return _get_tile_variant(4, 0)
		_:	
			return null