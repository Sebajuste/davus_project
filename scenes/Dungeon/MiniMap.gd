extends Node2D

var label := Label.new()
var f:Font = label.get_font("")
var _geometry := GeometryHelper.new()

var scale2D:int
var draw_room_index:bool
var graph_generator:GraphGenerator setget set_graph_generator
var player_position:Vector3

func gen(playerPos:Vector3):
	player_position = playerPos
	update()

func set_graph_generator(v):
	graph_generator = v
	update()


func _draw():
	if not graph_generator:
		return
	var viewportSize:Vector2 = get_parent().size
	var scaledMap:Vector2 = Vector2(graph_generator.map_width * scale2D, graph_generator.map_height * scale2D)
	var offset:Vector2 = (viewportSize - scaledMap) * 0.5
	var actual_room = graph_generator.pathfinding.get_closest_point(player_position)
	var segment = graph_generator.pathfinding.get_closest_position_in_segment(player_position)
	_draw_path(graph_generator.pathfinding, offset)
	for point in graph_generator.rooms_areas.keys():
		var room:Room = graph_generator.rooms_areas[point]
		var room_rect:Rect2 = room.get_room_rect()
		
		var color = Color.white
		if actual_room == point && room_rect.has_point(_geometry.vector2_ceil(_geometry.to_vector2(player_position))):
				color = Color.blue
		elif room == graph_generator.starting_room:
			color = Color.green
		elif room == graph_generator.ending_room:
			color = Color.red
		
		var scaled_room_rect = _geometry.scale_rectangle(
				room_rect, 
				scale2D, 
				true, 
				graph_generator.map_height
			)
		scaled_room_rect.position += offset
		draw_rect(scaled_room_rect, color, false)
		if draw_room_index:
			var pos = room.get_middle()
			draw_string(
				f, 
				offset + _geometry.reverse_y_axis(
					pos, 
					graph_generator.map_height
				) * scale2D, 
				str(point), 
				Color.red)


func _draw_path(path: AStar, offset:Vector2):
	if path:
		for point in path.get_points():
			for connection in path.get_point_connections(point):
				var pointPosition = path.get_point_position(point)
				var connectionPosition = path.get_point_position(connection)
				var scaledPointPos:Vector2 = offset + _geometry.reverse_y_axis(
						_geometry.to_vector2(pointPosition), 
						graph_generator.map_height
					) * scale2D
				
				var scaledConnectionPos:Vector2 = offset + _geometry.reverse_y_axis(
						_geometry.to_vector2(connectionPosition), 
						graph_generator.map_height
					) * scale2D
				
				draw_line(scaledPointPos, scaledConnectionPos, Color.yellow)

