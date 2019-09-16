extends "res://tools/StreamingLevel/LevelLayout.gd"

const MonsterLayoutBatch = preload("MonsterLayoutBatch.tscn")

const TILE_SIZE := 2

func gen(pos: Vector3) -> Spatial:
	var layout_batch = MonsterLayoutBatch.instance()
	layout_batch.translate( Vector3(pos.x*batch_size*TILE_SIZE, pos.y*batch_size*TILE_SIZE, 0) )
	layout_batch.gen( Vector3(pos.x*batch_size, pos.y*batch_size, 0), noise, cap )
	return layout_batch