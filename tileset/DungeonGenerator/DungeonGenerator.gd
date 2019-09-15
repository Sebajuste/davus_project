extends Node2D

export var scale2D = 2
export var room_margin = 2
export(int, 3, 13) var number_of_rooms = 15
export var number_of_keys = 1
export var map_width = 80
export var map_height = 50
export var min_room_width = 8
export var max_room_width = 10
export var min_room_height = 5
export var max_room_height = 6
export var map_seed = 2

signal graph_gen_finnished

enum eTilesType { Empty = -1, Door = 0, Wall = 1, Key = 2, End = 3, DoorInsertion = 4, Start = 5 }
enum eDirection { Top = 1, Right = 2, Bottom = 4, Left = 8 }
const DEBUG = true
const DESIRED_SEED_COUNTER = 1

var rooms_areas = Dictionary()
var starting_room = null
var ending_room = null
var pathfinding := AStar.new()
var rnd = RandomNumberGenerator.new()
var seed_counter = 1

var label = Label.new()
var f = label.get_font("")

func _ready():
	rnd.seed = map_seed
	gen_graph()

func _input(event):
	if event is InputEventKey and not event.is_pressed() and event.scancode == KEY_SPACE:
		clear_console()
		gen_graph()

func gen_graph():
	rooms_areas.clear()
	pathfinding = null
	rooms_areas = generate_rooms()
	pathfinding = generate_graph(rooms_areas.keys())
	update()
	emit_signal("graph_gen_finnished")

func generate_rooms() -> Dictionary:
	var rooms = Dictionary()
	for i in range(number_of_rooms):
		var room
		var collide = true
		while (collide):
			collide = false
			room = create_room()
			for other in rooms.values():
				if room.intersects(other):
					collide = true
			
			if not collide:
				rooms[get_middle(room)] = room
	return rooms

func create_room() -> Rect2:
	var width = (2 * room_margin + min_room_width + rnd.randi() % (max_room_width + 1 - min_room_width))
	var height = (2 * room_margin + min_room_height + rnd.randi() % (max_room_height + 1 - min_room_height))
	var x = rnd.randi() % (map_width - width)
	var y = rnd.randi() % (map_height - height)
	var pos = Vector2(floor(x), floor(y))
	var size = Vector2(width, height)
	return Rect2(pos, size)

func get_room_rectangle(area: Rect2) -> Rect2:
	return area.grow(- room_margin)

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
	for area in rooms_areas.values():
		var middleArea = get_middle(area)
		var pointArea = pathfinding.get_closest_point(middleArea)
		for other in rooms_areas.values():
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
	var distantest = get_distantest_rooms()
	starting_room = distantest[0]
	ending_room = distantest[1]
	var endingPoint = pathfinding.get_closest_point(get_middle(ending_room))
	write_corridors_on_map(map, endingPoint)
	var v = get_middle(starting_room)
	apply_tile_on_tilemap(map, v, eTilesType.Start)
	v = get_middle(ending_room)
	apply_tile_on_tilemap(map, v, eTilesType.End)
	
	seed_counter += 1
	if DEBUG && seed_counter < DESIRED_SEED_COUNTER || DESIRED_SEED_COUNTER == -1:
		gen_graph()


func fill_the_map(map: GridMap):
	for x in range(map_width):
		for y in range(map_height):
			var v = Vector3(x, y, 0)
			apply_tile_on_tilemap(map, v, eTilesType.Wall)


func write_rooms_on_map(map: GridMap):
	for area in rooms_areas.values():
		var room = get_room_rectangle(area)
		var left = room.position.x
		var right = left + room.size.x
		var top = room.position.y
		var bottom = top + room.size.y
		var z = 0
		for x in range(left, right):
			for y in range(top, bottom):
				var v = Vector3(x, y, z)
				apply_tile_on_tilemap(map, v, eTilesType.Empty)


func write_corridors_on_map(map: GridMap, room_point: int, rooms_done: Array = []):
	print(room_point)
	var posRoom1 = pathfinding.get_point_position(room_point)
	for connection in pathfinding.get_point_connections(room_point):
		if not connection in rooms_done:
			var posRoom2 = pathfinding.get_point_position(connection)
			var start = get_door_location(get_room_rectangle(rooms_areas[posRoom1]), posRoom2)
			var end = get_door_location(get_room_rectangle(rooms_areas[posRoom2]), posRoom1)
			dig_path(map, start, end, true, true)
			rooms_done.append(room_point)
			write_corridors_on_map(map, connection, rooms_done)


func dig_path(map: GridMap, start: Dictionary, end: Dictionary, doorOnStart: bool = false, doorOnEnd: bool = false):
	if start.size() > 0 && end.size() > 0:
		var startDir = start.keys()[0]
		var endDir = end.keys()[0]
		var startPos = to_vector3(start.values()[0])
		var endPos = to_vector3(end.values()[0])
		
		#var startPoint = pathfinding.get_closest_point(startPos)
		#var endPoint = pathfinding.get_closest_point(endPos)
		
		var horizontalStart = (startDir == eDirection.Left || startDir == eDirection.Right)
		var horizontalEnd = (endDir == eDirection.Left || endDir == eDirection.Right)
		var verticalStart = (startDir == eDirection.Top || startDir == eDirection.Bottom)
		var verticalEnd = (endDir == eDirection.Top || endDir == eDirection.Bottom)
		var horizontalPath = (horizontalStart && horizontalEnd)
		var verticalPath = (verticalStart && verticalEnd)
		
		#print(str(startPoint) + " -> " + str(endPoint) + " = " + str(start) + " -> " + str(end))
		if horizontalPath:		# Horizontal direction only
			dig_horizontally(map, startPos, endPos, doorOnStart, doorOnEnd)
		elif verticalPath:		# Vertical direction only
			dig_vertically(map, startPos, endPos, doorOnStart, doorOnEnd)
		else:					# Mixed directions
			if horizontalStart && verticalEnd:
				dig_mixed_directions(map, startPos, endPos, doorOnStart, doorOnEnd)
			elif verticalStart && horizontalEnd:
				dig_mixed_directions(map, endPos, startPos, doorOnEnd, doorOnStart)
		
		if DEBUG:
			apply_tile_on_tilemap(map, to_vector3(start.values()[0]), eTilesType.DoorInsertion)
			apply_tile_on_tilemap(map, to_vector3(end.values()[0]), eTilesType.DoorInsertion)
	
	else:
		print("Connections impossible, regénération de donjon : ")
		print("map_seed = " + str(map_seed))
		print("seed_counter = " + str(seed_counter))
		print("get_seed = " + str(rnd.seed))
		gen_graph()


func dig_horizontally(map: GridMap, startPos: Vector3, endPos: Vector3, doorOnStart: bool, doorOnEnd: bool):
	var dif = (endPos - startPos)
	startPos = vector3_floor(startPos)
	endPos = vector3_floor(endPos)
	var middlePos = vector3_round(startPos + (dif / 2))
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	for x in range(startPos.x, endPos.x + step.x, step.x):
		var v : Vector3
		if x < middlePos.x && step.x > 0 || x > middlePos.x && step.x < 0:
			v = Vector3(x, startPos.y, 0)
		else:
			v = Vector3(x, endPos.y, 0)
		if doorOnStart && x == startPos.x + step.x ||doorOnEnd && x == endPos.x - step.x:
			apply_tile_on_tilemap(map, v, eTilesType.Door)
		else:
			apply_tile_on_tilemap(map, v, eTilesType.Empty)
		
	for y in range(startPos.y, endPos.y + step.y, step.y):
		var v = Vector3(middlePos.x, y, 0)
		apply_tile_on_tilemap(map, v, eTilesType.Empty)


func dig_vertically(map: GridMap, startPos: Vector3, endPos: Vector3, doorOnStart: bool, doorOnEnd: bool):
	var dif = (endPos - startPos)
	startPos = vector3_floor(startPos)
	endPos = vector3_floor(endPos)
	var middlePos = vector3_round(startPos + (dif / 2))
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	for y in range(startPos.y, endPos.y + step.y, step.y):
		var v : Vector3
		if y < middlePos.y && step.y > 0 || y > middlePos.y && step.y < 0:
			v = Vector3(startPos.x, y, 0)
		else:
			v = Vector3(endPos.x, y, 0)
		if doorOnStart && y == startPos.y + step.y || doorOnEnd && y == endPos.y - step.y:
			apply_tile_on_tilemap(map, v, eTilesType.Door)
		else:
			apply_tile_on_tilemap(map, v, eTilesType.Empty)
		
	for x in range(startPos.x, endPos.x + step.x, step.x):
		var v = Vector3(x, middlePos.y, 0)
		apply_tile_on_tilemap(map, v, eTilesType.Empty)


func dig_mixed_directions(map: GridMap, horizontalPos: Vector3, verticalPos: Vector3, doorOnHorizontal: bool, doorOnVertical: bool):
	var dif = (verticalPos - horizontalPos)
	horizontalPos = vector3_floor(horizontalPos)
	verticalPos = vector3_floor(verticalPos)
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	for x in range(horizontalPos.x, verticalPos.x, step.x):
		var v = Vector3(x, horizontalPos.y, 0)
		if doorOnHorizontal && x == horizontalPos.x + step.x:
			apply_tile_on_tilemap(map, v, eTilesType.Door)
		else:
			apply_tile_on_tilemap(map, v, eTilesType.Empty)
	
	for y in range(horizontalPos.y, verticalPos.y, step.y):
		var v = Vector3(verticalPos.x, y, 0)
		if doorOnVertical && y == verticalPos.y - step.y:
			apply_tile_on_tilemap(map, v, eTilesType.Door)
		else:
			apply_tile_on_tilemap(map, v, eTilesType.Empty)


func get_door_location(rect: Rect2, point: Vector3) -> Dictionary:
	var middle = to_vector2(get_middle(rect))
	var point2D = to_vector2(point)
	var topRight = rect.position + (rect.size * Vector2.RIGHT)
	var bottomLeft = rect.position + (rect.size * Vector2.DOWN)
	var bottomRight = rect.position + rect.size
	var dir = (point2D - middle).normalized()
	var intersections = Dictionary()
	intersections[eDirection.Top] = get_line_intersection(rect.position, topRight, middle, point2D)
	intersections[eDirection.Bottom] = get_line_intersection(bottomLeft, bottomRight, middle, point2D) - dir
	intersections[eDirection.Right] = get_line_intersection(topRight, bottomRight, middle, point2D) - dir
	intersections[eDirection.Left] = get_line_intersection(rect.position, bottomLeft, middle, point2D)
	for direction in intersections.keys():
		var intersection = intersections[direction]
		if intersection == Vector2.INF:
			intersections.erase(direction)
	return intersections


func get_line_intersection(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> Vector2:
	var denominator = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
	if denominator != 0:
		var t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / denominator
		var u = -((p1.x - p2.x) * (p1.y - p3.y) - (p1.y - p2.y) * (p1.x - p3.x)) / denominator
		if (t >= 0 && t < 1 && u >= 0 && u < 1):
			return Vector2(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y));
	return Vector2.INF


func apply_tile_on_tilemap(map: GridMap, pos: Vector3, tileType: int):
	map.set_cell_item(pos.x, pos.y, pos.z, tileType)

func to_vector3(v: Vector2, z :int = 0) -> Vector3:
	return Vector3(v.x, v.y, z)

func vector3_ceil(v: Vector3) -> Vector3:
	return Vector3(ceil(v.x), ceil(v.y), ceil(v.z))

func vector3_floor(v: Vector3) -> Vector3:
	return Vector3(floor(v.x), floor(v.y), floor(v.z))

func vector3_round(v: Vector3) -> Vector3:
	return Vector3(round(v.x), round(v.y), round(v.z))


func vector2_ceil(v: Vector2) -> Vector2:
	return Vector2(ceil(v.x), ceil(v.y))

func vector2_floor(v: Vector2) -> Vector2:
	return Vector2(floor(v.x), floor(v.y))

func vector2_round(v: Vector2) -> Vector2:
	return Vector2(round(v.x), round(v.y))

func to_vector2(v: Vector3) -> Vector2:
		return Vector2(v.x, v.y)


func reverse_y_axis(v: Vector2):
	return Vector2(v.x, map_height - v.y)

func get_middle(r: Rect2) -> Vector3:
	return to_vector3(r.position + (r.size * 0.5))

func scale_rectangle(r: Rect2, scale: int, reverseY: bool = false) -> Rect2:
		if reverseY:
			var pos = Vector2(r.position.x, r.position.y + r.size.y - map_height / 2)
			return Rect2(reverse_y_axis(pos * scale), r.size * scale)
		else:
			return Rect2(r.position * scale, r.size * scale)

func _draw():
	for area in rooms_areas.values():
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
			
func clear_console():
	var escape := PoolByteArray([0x1b]).get_string_from_ascii()
	print(escape + "[2J" + escape + "[;H")