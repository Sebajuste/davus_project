extends Node

signal batch_generated(batch)

export var noise: OpenSimplexNoise

export(float, -1.0, 1.0) var cap := 0.0


var batch_size: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func gen(pos: Vector3) -> Spatial:
	return null
