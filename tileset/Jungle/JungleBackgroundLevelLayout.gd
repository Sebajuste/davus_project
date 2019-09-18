extends "res://tools/StreamingLevel/LevelLayout.gd"

onready var GIANT_LIANA = load("res://models/Background/giantLiana.glb")
onready var GIANT_LIANA_NO_LEAVES = load("res://models/Background/giantLianaNoLeaves.glb")

const TILE_SIZE = 2

export var top_max_y := -2
export(float, -1.0, 1.0) var top_max_value := 0.0
export var end_max_y := 0

func gen(loc: Vector3) -> Spatial:
	
	var batch = Spatial.new()
	batch.translate( Vector3(loc.x*batch_size*TILE_SIZE, loc.y*batch_size*TILE_SIZE, 0) )
	
	if loc.y < end_max_y:
		var liana = GIANT_LIANA.instance()
		batch.add_child(liana)
		liana.translate( Vector3(16, 16, -10) )
		liana.scale_object_local( Vector3(1.2, 1.2, 1.2) )
	
	if loc.y < top_max_y:
		var liana = GIANT_LIANA_NO_LEAVES.instance()
		batch.add_child(liana)
		liana.translate( Vector3(16, 16, -30) )
		liana.scale_object_local( Vector3(1.5, 1.5, 1.5) )
	
	return batch