extends "res://tools/StreamingLevel/LayoutBatch.gd"


const TILES_RESOURCES := { 
	0x00:
		[ # Full
			preload("res://models/Tiles/Jungle/tilePlain.glb"),
		],
	0x01:
		[
			preload("res://models/Tiles/Jungle/tileFloor.glb"),
		],
	0x02:
		[
			preload("res://models/Tiles/Jungle/tileRoof.glb"),
		],
	}

var top_max_y : int
var top_max_value : float
var end_max_y : int

func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if global_pos.y < end_max_y and _is_solid_tile(global_pos, noise, cap):
				var mask = _create_bitmask( global_pos, noise, cap)
				var tile = _create_tile(mask)
				if tile:
					self.add_child(tile)
					tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )


func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap


func _create_bitmask(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> int:
	
	var mask = 0x00
	var index = 0
	
	for i in range(1, -2, -2):
		# Top / Bottom
		var top_bottom_global_pos = global_pos + Vector3(0, i, 0)
		if not _is_solid_tile(top_bottom_global_pos, noise, cap):
			mask |= 0x01 << index
		
		# Left / Right
		var left_right_global_pos = global_pos + Vector3(i, 0, 0)
		if not _is_solid_tile(left_right_global_pos, noise, cap):
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