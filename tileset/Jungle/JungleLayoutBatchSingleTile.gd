extends "res://tools/StreamingLevel/LayoutBatch.gd"

const TILE_MESH = preload("res://models/Tiles/Jungle/omniTile.mesh")

const STATIC_TILE = preload("res://tileset/Jungle/StaticBody.tscn")

export var debug := false setget set_debug

onready var tile_shape = load("res://tileset/Jungle/tile.shape")

var top_max_y : int
var top_max_value : float
var end_max_y : int


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


func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	
	var mesh_position_list := []
	
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if global_pos.y < end_max_y and _is_solid_tile(global_pos, noise, cap):
				var pos = Vector3(x*2, (size*2)-(y*2), 0)
				mesh_position_list.append( pos )
				
				var static_body = STATIC_TILE.instance()
				self.add_child(static_body)
				static_body.translate(pos)
	
	var multimesh = MultiMesh.new()
	multimesh.mesh = TILE_MESH
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = mesh_position_list.size()
	$MultiMeshInstance.multimesh = multimesh
	
	var basis = Basis()
	for index in range(mesh_position_list.size()):
		$MultiMeshInstance.multimesh.set_instance_transform(index, Transform(basis,  mesh_position_list[index]) )
	

func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap
