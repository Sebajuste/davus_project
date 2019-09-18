extends "res://tools/StreamingLevel/LayoutBatch.gd"

const tile_mesh = preload("res://models/Tiles/Jungle/omniTile.mesh")
#const tile_mesh = preload("tile_mesh.tres")

#const Tile = preload("Test.tscn")

"""
func _ready():
	var multimesh = MultiMesh.new()
	multimesh.mesh = tile_mesh
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	#multimesh.instance_count = mesh_position_list.size()
	multimesh.instance_count = 0
	$MultiMeshInstance.multimesh = multimesh
"""

func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	
	var mesh_position_list := []
	
	for x in range(size):
		for y in range(size):
			var global_pos = Vector3(loc.x+x, loc.y-y, 0)
			if _is_solid_tile(global_pos, noise, cap):
				mesh_position_list.append( Vector3(x*2, (size*2)-(y*2), 0) )
				"""
				var tile = Tile.instance()
				self.add_child(tile)
				tile.translate( Vector3(x*2, (size*2)-(y*2), 0) )
				"""
	
	print("count: ", mesh_position_list.size() )
	
	
	var multimesh = MultiMesh.new()
	multimesh.mesh = tile_mesh
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	#multimesh.instance_count = mesh_position_list.size()
	#multimesh.instance_count = 0
	$MultiMeshInstance.multimesh = multimesh
	
	$MultiMeshInstance.multimesh.instance_count = mesh_position_list.size()
	#$MultiMeshInstance.multimesh.visible_count_instance = mesh_position_list.size()
	
	
	
	var basis = Basis()
	for index in range(mesh_position_list.size()):
		#print(index, " ", mesh_position_list[index])
		$MultiMeshInstance.multimesh.set_instance_transform(index, Transform(basis,  mesh_position_list[index]) )
		#multimesh.set_instance_transform(index, Transform(basis,  mesh_position_list[index]) )
		#print("test")
	
	#$MultiMeshInstance.multimesh = multimesh
	

func _is_solid_tile(global_pos: Vector3, noise: OpenSimplexNoise, cap: float) -> bool:
	return noise.get_noise_2d(global_pos.x, global_pos.y) > cap
