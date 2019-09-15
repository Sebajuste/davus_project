extends "res://tools/StreamingLevel/LevelLayout.gd"

const TestLayoutBatch = preload("res://tileset/Test/TestLayoutBatch.tscn")

const TILE_SIZE := 2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func gen(loc: Vector3) -> Spatial:
	
	var level_batch = TestLayoutBatch.instance()
	
	level_batch.translate( Vector3(loc.x*batch_size*TILE_SIZE, loc.y*batch_size*TILE_SIZE, 0) )
	level_batch.gen( Vector3(loc.x*batch_size, loc.y*batch_size, 0), noise, cap )
	
	return level_batch
