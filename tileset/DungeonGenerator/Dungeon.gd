extends Spatial

func _on_DungeonGenerator_graph_gen_finnished():
	var dg = $DungeonGenerator
	dg.generate_grid_map($GridMap)
	$Camera.translation.x = dg.map_width * dg.tile_size
	$Camera.translation.y = dg.map_height * dg.tile_size