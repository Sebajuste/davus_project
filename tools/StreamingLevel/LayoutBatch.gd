extends Node

export var size := 16
export var debug := false setget set_debug


func set_debug(v):
	debug = v
	$ImmediateGeometry.clear()
	if debug:
		$ImmediateGeometry.begin(Mesh.PRIMITIVE_LINE_LOOP)
		
		$ImmediateGeometry.set_color(Color(1.0, 0.0, 0.0))
		
		$ImmediateGeometry.add_vertex(Vector3(0, 0, 1))
		$ImmediateGeometry.add_vertex(Vector3(size*2, 0, 1))
		$ImmediateGeometry.add_vertex(Vector3(size*2, size*2, 1))
		$ImmediateGeometry.add_vertex(Vector3(0, size*2, 1))
		
		$ImmediateGeometry.end()


# Must be override
func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	pass
