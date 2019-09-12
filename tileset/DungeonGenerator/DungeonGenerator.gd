extends Node2D

export var scale2D = 2
export var tile_size = 2
export var room_margin = 1
export(int, 3, 13) var number_of_rooms = 12
export var number_of_keys = 1
export var map_width = 40
export var map_height = 25
export var min_room_size = 5
export var max_room_size = 10
export var map_seed = 2

signal graph_gen_finnished

enum eTilesType { Empty = -1, Door = 0, Wall = 1, Key = 2 }

var rooms_areas = Array()
var starting_room = null
var ending_room = null
var pathfinding := AStar.new()
var rnd = RandomNumberGenerator.new()

var label = Label.new()
var f = label.get_font("")

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
		astar.connect_points(astar.get_closest_point(current_position), point)
		locations.erase(closest_position)
	return astar

func get_distantest_rooms() -> Array:
	var result = Array()
	var a1 = null
	var a2 = null
	var distanceMax = 0
	var roomsBetweenMax = 0
	for area in rooms_areas:
		var middleArea = get_middle(area)
		var pointArea = pathfinding.get_closest_point(middleArea)
		for other in rooms_areas:
			if area != other:
				var middleOther = get_middle(other)
				var pointOther = pathfinding.get_closest_point(middleOther)
				var path = pathfinding.get_id_path(pointArea, pointOther)
				var roomsBetween = path.size()
				var isDistantest = false
				var distance = middleArea.distance_to(middleOther)
				if roomsBetween > roomsBetweenMax:
					roomsBetweenMax = roomsBetween
					isDistantest = true
				elif roomsBetween == roomsBetweenMax:
					if distance > distanceMax:
						isDistantest = true
				
				if isDistantest:
					a1 = area
					a2 = other
					distanceMax = distance
	
	result.append(a1)
	result.append(a2)
	return result

func generate_grid_map(map:GridMap):
	map.clear()
	fill_the_map(map)
	write_rooms_on_map(map)
	write_corridors_on_map(map)
	var distantest = get_distantest_rooms()
	starting_room = distantest[0]
	ending_room = distantest[1]
	for a in distantest:
		var v = get_middle(a)
		apply_tile_on_tilemap(map, v, eTilesType.Key)


func fill_the_map(map: GridMap):
	for x in range(map_width * tile_size):
		for y in range(map_height * tile_size):
			var v = Vector3(x, y, 0)
			apply_tile_on_tilemap(map, v, eTilesType.Wall)


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
				var v = Vector3(x, y, z)
				apply_tile_on_tilemap(map, v, eTilesType.Empty)


func write_corridors_on_map(map: GridMap):
	var rooms_done = []
	for area in rooms_areas:
		var point = pathfinding.get_closest_point(get_middle(area))
		for connection in pathfinding.get_point_connections(point):
			if not connection in rooms_done:
				var start = pathfinding.get_point_position(point)
				var end = pathfinding.get_point_position(connection)
				dig_path(map, start, end)
		
		rooms_done.append(point)


func dig_path(map: GridMap, start: Vector3, end: Vector3):
	var diff = end - start
	var step = Vector2(sign(diff.x), sign(diff.y))
	if step.x == 0: step.x = pow(-1, rnd.randi() % 2)
	if step.y == 0: step.y = pow(-1, rnd.randi() % 2)
	var collidorSize = 2 #rnd.randi() % 3 + 1
	for x in range(start.x, end.x, step.x):
		for y in range(start.y, start.y + step.y * collidorSize, step.y):
			var v = Vector3(x, y, 0)
			apply_tile_on_tilemap(map, v, eTilesType.Empty)
	for y in range(start.y, end.y, step.y):
		for x in range(end.x, end.x + step.x * collidorSize, step.x):
			var v = Vector3(x, y, 0)
			apply_tile_on_tilemap(map, v, eTilesType.Empty)

func apply_tile_on_tilemap(map: GridMap, pos: Vector3, tileType: int):
	map.set_cell_item(pos.x, pos.y, pos.z, tileType)

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
		var rect = scale_rectangle(area, scale2D, true)
		var pos = get_middle(rect)
		var point = pathfinding.get_closest_point(get_middle(area))
		draw_string(f, to_vector2(pos * 6), str(point), Color.red)
		draw_rect(rect, Color.white, false)						# draw area
		var color = Color.blue
		if area == starting_room:
			color = Color.green
		elif area == ending_room:
			color = Color.red
		draw_rect(scale_rectangle(get_room_rectangle(area), scale2D, true), color, false)	# draw room (without margin)
	draw_path(pathfinding)

func draw_path(path: AStar):
	if path:
		for point in path.get_points():
			for edges in path.get_point_connections(point):
				var pointPosition = path.get_point_position(point)
				var edgePosition = path.get_point_position(edges)
				draw_line(reverse_y_axis(to_vector2(pointPosition)) * scale2D, reverse_y_axis(to_vector2(edgePosition)) * scale2D, Color.yellow)