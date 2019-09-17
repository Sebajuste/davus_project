extends "res://tools/StreamingLevel/LevelLayout.gd"

const JungleLayoutBatch = preload("JungleLayoutBatch.tscn")

const TILE_SIZE := 2

export var top_y := -2
export var top_cap := 0.0
export var end_y := 0

func gen(loc: Vector3) -> Spatial:
	var layout_batch = JungleLayoutBatch.instance()
	layout_batch.top_y = top_y
	layout_batch.top_cap = top_cap
	layout_batch.end_y = end_y
	layout_batch.translate( Vector3(loc.x*batch_size*TILE_SIZE, loc.y*batch_size*TILE_SIZE, 0) )
	layout_batch.gen( Vector3(loc.x*batch_size, loc.y*batch_size, 0), noise, cap )
	
	return layout_batch

