extends Spatial


export var size := 16

export(float, -1.0, 1.0) var cap := 0.15

export var debug := true

var _noise

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
			
			var value = _noise.get_noise_2d(pos.x, pos.y)
			var mask = 0
			if value <= cap:
				mask = _create_bitmask( pos )
			else:
				mask = 0x10
			
			var tile = _create_tile(mask)
			if tile:
				self.add_child(tile)
				tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _create_bitmask(pos: Vector3) -> int:
	
	var mask = 0x00
	var index = 0
	
	for i in range(1, -2, -2):
		# Top / Bottom
		if _noise.get_noise_2d(pos.x, pos.y + i) > cap:
			mask |= 0x01 << index
		
		# Left / Right
		if _noise.get_noise_2d(pos.x + i, pos.y) > cap:
			mask |= 0x02 << index
			
		index += 2
		
	return mask


func _create_tile(mask: int) -> Node:
	
	match mask:
		0x01:	# Top tile
			return load("res://tileset/Jungle/Tile01.glb").instance()
		0x02:	# Right tile
			return load("res://tileset/Jungle/Tile02.glb").instance()
		0x03:	# Top & Right tile
			return load("res://tileset/Jungle/Tile03.glb").instance()
		0x04:	# Bottom tile
			return load("res://tileset/Jungle/Tile04.glb").instance()
		0x05:	# Top & Bottom tile
			return load("res://tileset/Jungle/Tile05.glb").instance()
		0x06:	# Right & Bottom tile
			return load("res://tileset/Jungle/Tile06.glb").instance()
		0x07:	# Top & Right & Bottom tile
			return load("res://tileset/Jungle/Tile07.glb").instance()
		0x08:	# Left tile
			return load("res://tileset/Jungle/Tile08.glb").instance()
		0x09:	# Top & Left tile
			return load("res://tileset/Jungle/Tile09.glb").instance()
		0x0A:	# Right & Left tile
			return load("res://tileset/Jungle/Tile10.glb").instance()
		0x0B:	# Top & Right & Left tile
			return load("res://tileset/Jungle/Tile11.glb").instance()
		0x0C:	# Bottom & Left tile
			return load("res://tileset/Jungle/Tile12.glb").instance()
		0x0D:	# Top & Bottom & Left tile
			return load("res://tileset/Jungle/Tile13.glb").instance()
		0x0E:	# Right & Bottom & Left tile
			return load("res://tileset/Jungle/Tile14.glb").instance()
		0x0F:	# Top & Right & Bottom & Left tile
			return load("res://tileset/Jungle/Tile15.glb").instance()
		0x10:	# Full tile
			return load("res://tileset/Jungle/Tile00.glb").instance()
		_:
			return null