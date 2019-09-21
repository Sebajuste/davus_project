extends Node2D

"""
func _draw():
	for area in rooms_areas.values():
		var rect = geometry.scale_rectangle(area, scale2D, true)
		if DRAW_ROOMS_INDEX:
			var pos = get_middle(rect)
			var point = pathfinding.get_closest_point(get_middle(area))
			draw_string(f, to_vector2(pos * 6), str(point), Color.red)
		draw_rect(rect, Color.white, false)						# draw area
		var color = Color.blue
		if area == starting_room:
			color = Color.green
		elif area == ending_room:
			color = Color.red
		draw_rect(scale_rectangle(_get_room_rectangle(area), scale2D, true), color, false)	# draw room (without margin)
	_draw_path(pathfinding)

func _draw_path(path: AStar):
	if path:
		for point in path.get_points():
			for edges in path.get_point_connections(point):
				var pointPosition = path.get_point_position(point)
				var edgePosition = path.get_point_position(edges)
				draw_line(reverse_y_axis(to_vector2(pointPosition)) * scale2D, reverse_y_axis(to_vector2(edgePosition)) * scale2D, Color.yellow)
"""