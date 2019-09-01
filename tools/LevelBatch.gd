extends Spatial


export var size := 16

export(float, -1.0, 1.0) var cap := 0.15

export var debug := true

var _noise
const TILES_RESOURCES := {
    0x01: preload("res://models/World/Test/Tile01.glb"), # Top tile
    0x02: preload("res://models/World/Test/Tile02.glb"), # Right tile
    0x03: preload("res://models/World/Test/Tile03.glb"), # Top & Right tile
    0x04: preload("res://models/World/Test/Tile04.glb"), # Bottom tile
    0x05: preload("res://models/World/Test/Tile05.glb"), # Top & Bottom tile
    0x06: preload("res://models/World/Test/Tile06.glb"), # Right & Bottom tile
    0x07: preload("res://models/World/Test/Tile07.glb"), # Top & Right & Bottom tile
    0x08: preload("res://models/World/Test/Tile08.glb"), # Left tile
    0x09: preload("res://models/World/Test/Tile09.glb"), # Top & Left tile
    0x0A: preload("res://models/World/Test/Tile10.glb"), # Right & Left tile
    0x0B: preload("res://models/World/Test/Tile11.glb"), # Top & Right & Left tile
    0x0C: preload("res://models/World/Test/Tile12.glb"), # Bottom & Left tile
    0x0D: preload("res://models/World/Test/Tile13.glb"), # Top & Bottom & Left tile
    0x0E: preload("res://models/World/Test/Tile14.glb"), # Right & Bottom & Left tile
    0x0F: preload("res://models/World/Test/Tile15.glb"), # Top & Right & Bottom & Left tile
    0x10: preload("res://models/World/Test/Tile00.glb"), # Full tile
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
	
    if TILES_RESOURCES.has(mask):
        return TILES_RESOURCES.get(mask).instance()
    else:
        return null