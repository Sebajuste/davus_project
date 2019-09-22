extends Node2D

var label := Label.new()
var f:Font = label.get_font("")
var _geometry := GeometryHelper.new()

var scale2D:int
var draw_room_index:bool
var graph_generator:GraphGenerator

func gen():
	update()

func _draw():
	_draw_path(graph_generator.pathfinding)
	for point in graph_generator.rooms_areas.keys():
		var room:Room = graph_generator.rooms_areas[point]
		var rect = _geometry.scale_rectangle(room.area, scale2D, true, graph_generator.map_height)
		draw_rect(rect, Color.white, false)						# draw room
		var color = Color.blue
		if room == graph_generator.starting_room:
			color = Color.green
		elif room == graph_generator.ending_room:
			color = Color.red
		draw_rect(
			_geometry.scale_rectangle(
				room.get_room_rect(), 
				scale2D, 
				true, 
				graph_generator.map_height
			), 
			color, 
			false
		)	# draw room (without margin)
		if draw_room_index:
			var pos = room.get_middle()
			draw_string(f, _geometry.reverse_y_axis(pos, graph_generator.map_height) * scale2D, str(point), Color.red)

func _draw_path(path: AStar):
	if path:
		for point in path.get_points():
			for edges in path.get_point_connections(point):
				var pointPosition = path.get_point_position(point)
				var edgePosition = path.get_point_position(edges)
				draw_line(_geometry.reverse_y_axis(_geometry.to_vector2(pointPosition), graph_generator.map_height) * scale2D, _geometry.reverse_y_axis(_geometry.to_vector2(edgePosition), graph_generator.map_height) * scale2D, Color.yellow)