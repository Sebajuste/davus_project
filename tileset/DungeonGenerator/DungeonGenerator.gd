extends Node2D

export var scale2D = 2
export var tile_size = 2
export var room_margin = 1
export(int, 3, 13) var number_of_rooms = 5
export var map_width = 40
export var map_height = 25
export var min_room_size = 5
export var max_room_size = 10
export var map_seed = 2

signal graph_gen_finnished

enum eTilesType { Empty = -1, Floor = 0, Wall = 1 }

var rooms_areas = Array()
var pathfinding := AStar.new()
var rnd = RandomNumberGenerator.new()

func _ready():
	rnd.seed = map_seed
	gen_graph()

func _input(event):
	if event is InputEventKey and not event.is_pressed() and event.scancode == KEY_SPACE:
		gen_graph()

func gen_graph():
	rooms_areas.clear()
	pathfinding = null
	var roomLocations = generate_rooms()
	pathfinding = generate_graph(roomLocations)
	update()
	emit_signal("graph_gen_finnished")

func generate_rooms() -> Array:
	var locations = Array()
	for i in range(number_of_rooms):
		var room
		var collide = true
		while (collide):
			collide = false
			room = create_room()
			for other in rooms_areas:
				if room.intersects(other):
					collide = true
			
			if not collide:
				rooms_areas.append(room)
				locations.append(get_middle(room))
	
	return locations

func create_room() -> Rect2:
	var width = (min_room_size + rnd.randi() % (max_room_size - min_room_size)) * tile_size
	var height = (min_room_size + rnd.randi() % (max_room_size - min_room_size)) * tile_size
	var x = rnd.randi() % (map_width * tile_size - width)
	var y = rnd.randi() % (map_height * tile_size - height)
	var pos = Vector2(x - (x % tile_size), y - (y % tile_size))
	var size = Vector2(width, height)
	return Rect2(pos, size)

func get_room_rectangle(area: Rect2) -> Rect2:
	return area.grow(- room_margin * tile_size)

func generate_graph(locations: Array) -> AStar:
	var astar = AStar.new()
	astar.add_point(astar.get_available_point_id(), locations.pop_front())
	while locations:
		var current_position
		var closest_position
		var min_distance = INF
		
		for point in astar.get_points():
			var pos = astar.get_point_position(point)
			for otherPos in locations:
				var dist = pos.distance_to(otherPos)
				if dist < min_distance:
					min_distance = dist
					current_position = pos
					closest_position = otherPos
					
		var point = astar.get_available_point_id()
		astar.add_point(point, closest_position)
		astar.connect_points(astar.get_closest_point(current_position), point, false)
		locations.erase(closest_position)
	return astar


func generate_grid_map(map:GridMap):
	map.clear()
	fill_the_map(map)
	write_rooms_on_map(map)
	write_corridors_on_map(map)

func fill_the_map(map: GridMap):
	for x in range(map_width * tile_size):
		for y in range(map_height * tile_size):
			map.set_cell_item(x, y, 0, eTilesType.Wall)

func write_rooms_on_map(map: GridMap):
	for area in rooms_areas:
		var room = get_room_rectangle(area)
		var left = room.position.x
		var right = left + room.size.x
		var top = room.position.y
		var bottom = top + room.size.y
		var z = 0
		for x in range(left, right + 1):
			for y in range(top, bottom + 1):
				map.set_cell_item(x, y, z, eTilesType.Empty)	# room floor
				if x == left or x == right or y == top or y == bottom:
					map.set_cell_item(x, y, z, eTilesType.Empty)	# room walls


func write_corridors_on_map(map: GridMap):
	for area in rooms_areas:
		var corridors = []
		var point = pathfinding.get_closest_point(get_middle(area))
		for connection in pathfinding.get_point_connections(point):
			if not connection in corridors:
				var start = pathfinding.get_point_position(point)
				var end = pathfinding.get_point_position(connection)
				dig_path(map, start, end)
				corridors.append(connection)


func dig_path(map: GridMap, start: Vector3, end: Vector3):
	var xStep = sign(end.x - start.x)
	var yStep = sign(end.y - start.y)
	if xStep == 0: xStep = pow(-1, rnd.randi() % 2)
	if yStep == 0: yStep = pow(-1, rnd.randi() % 2)
	var x_to_y = start		# Direction horizontal and vertical
	var y_to_x = end		# Direction vertical and horizontal
	var z = 0
	if rnd.randi() % 2 == 0:
		y_to_x = start
		x_to_y = end
	for x in range(start.x, end.x + xStep, xStep): # + xStep * 2, xStep):
		#map.set_cell_item(x, x_to_y.y - yStep, z, eTilesType.Empty)
		map.set_cell_item(x, x_to_y.y, z, eTilesType.Empty)
		map.set_cell_item(x, x_to_y.y + yStep, z, eTilesType.Empty)
	for y in range(start.y, end.y + yStep, yStep): # + yStep * 2, yStep):
		#map.set_cell_item(y_to_x.x - xStep, y, z, eTilesType.Empty)
		map.set_cell_item(y_to_x.x, y, z, eTilesType.Empty)
		map.set_cell_item(y_to_x.x + xStep, y, z, eTilesType.Empty)


func to_vector3(v: Vector2, z :int = 0) -> Vector3:
	return Vector3(v.x, v.y, z)
	
func to_vector2(v: Vector3) -> Vector2:
		return Vector2(v.x, v.y)

func reverse_y_axis(v: Vector2):
	return Vector2(v.x, map_height * tile_size -v.y) 

func get_middle(r: Rect2) -> Vector3:
	return to_vector3(r.position + (r.size / 2))

func scale_rectangle(r: Rect2, scale: int, reverseY: bool = false) -> Rect2:
		if reverseY:
			var pos = Vector2(r.position.x, r.position.y + r.size.y - map_height * tile_size / 2)
			return Rect2(reverse_y_axis(pos * scale), r.size * scale)
		else:
			return Rect2(r.position * scale, r.size * scale)

func _draw():
	for area in rooms_areas:
		draw_rect(scale_rectangle(area, scale2D, true), Color.white, false)						# draw area
		draw_rect(scale_rectangle(get_room_rectangle(area), scale2D, true), Color.red, true)	# draw room (without margin)
	draw_path(pathfinding)

func draw_path(path: AStar):
	if path:
		for point in path.get_points():
			for edges in path.get_point_connections(point):
				var pointPosition = path.get_point_position(point)
				var edgePosition = path.get_point_position(edges)
				draw_line(reverse_y_axis(to_vector2(pointPosition)) * scale2D, reverse_y_axis(to_vector2(edgePosition)) * scale2D, Color.yellow)