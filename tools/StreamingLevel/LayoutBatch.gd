extends Node

export var size := 16
#export(float, -1.0, 1.0) var cap := 0.15
export var debug := true

#export var noise: OpenSimplexNoise

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Must be override
func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	pass
