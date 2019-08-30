extends Spatial


const Test = preload("res://tileset/test/Test.tscn")

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
			if value > cap:
				var mask = _create_bitmask( pos )
				var tile = _create_tile(mask)
				if tile:
					self.add_child(tile)
					tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _create_bitmask(pos: Vector3) -> int:
	
	var mask = 0x00
	
	var index = 0
	for x in range(-1, 2):
		for y in range(-1, 2):
			if not(x == 0 and y == 0):
				if _noise.get_noise_2d(pos.x+x, pos.y+y) > cap:
					mask |= 0x01 << index
				
				index += 1
	
	return mask

func _create_tile(mask: int) -> Node:
	
	"""
	match mask & 0x5a:
		0x00:
			return load("res://tileset/Jungle/Tile00.glb").instance()
		0x08:
			return load("res://tileset/Jungle/Tile01.glb").instance()
		0x40:
			return load("res://tileset/Jungle/Tile02.glb").instance()
		0x48:
			return load("res://tileset/Jungle/Tile03.glb").instance()
		0x10:
			return load("res://tileset/Jungle/Tile04.glb").instance()
		0x18:
			return load("res://tileset/Jungle/Tile05.glb").instance()
		0x50:
			return load("res://tileset/Jungle/Tile06.glb").instance()
		0x58:
			return load("res://tileset/Jungle/Tile07.glb").instance()
		0x02:
			return load("res://tileset/Jungle/Tile08.glb").instance()
		0x0A:
			return load("res://tileset/Jungle/Tile09.glb").instance()
		0x42:
			return load("res://tileset/Jungle/Tile10.glb").instance()
		0x4A:
			return load("res://tileset/Jungle/Tile11.glb").instance()
		0x12:
			return load("res://tileset/Jungle/Tile12.glb").instance()
		0x1A:
			return load("res://tileset/Jungle/Tile13.glb").instance()
		0x52:
			return load("res://tileset/Jungle/Tile14.glb").instance()
		_:
			return load("res://tileset/Jungle/Tile00.glb").instance()
	"""
	
	return load("res://tileset/test/Test.tscn").instance()
