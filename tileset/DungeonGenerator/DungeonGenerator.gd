extends Node2D

signal graph_gen_finnished
signal dungeon_generated

export var scale2D:int = 2
export var room_margin:int = 2
export(int, 2, 10) var number_of_rooms:int = 12
export var number_of_keys:int = 1
export var map_width:int = 80
export var map_height:int = 50
export var min_room_width:int = 5
export var max_room_width:int = 8
export var min_room_height:int = 3
export var max_room_height:int = 3
export var map_seed = 1

const TILE_SIZE = 2

const DEBUG = false
const FORCE_START_DOOR = false
const FORCE_END_DOOR = false
const DISABLE_COLLISION = false
const DRAW_ROOMS_INDEX = false
const PRINT_REFUSED_DUNGEON = true
const PRINT_LADDER = false
const PRINT_ROOMS_TRAVEL = false
const PRINT_DOOR_LOCATION = false
const DESIRED_SEED_STEP_COUNTER = 132
var _desired_seed_counter:int = 0 #100


enum eDirection { Top = 1, Right = 2, Bottom = 4, Left = 8 }
enum eTilesType { Empty = -1, Door = 0, Wall = 1, Key = 2, Start = 3, End = 4, DoorInsertion = 5, LeftLadder = 6, RightLadder = 7 }
const STATIC_BODIES:Dictionary = { 
	eTilesType.Door: preload("res://tileset/test/Door.tscn"),
	eTilesType.Wall: preload("res://tileset/test/Wall.tscn"),
	eTilesType.LeftLadder: preload("res://tileset/test/LeftLadder.tscn"),
	eTilesType.RightLadder: preload("res://tileset/test/RightLadder.tscn"),
	}
	
const ROOM_PREFAB:Dictionary = {
	5:
		{
			3: preload("res://tileset/test/Prefab_5x3.tscn"),
			4: preload("res://tileset/test/Prefab_5x4.tscn"),
		},
	6:
		{
			3: preload("res://tileset/test/Prefab_6x3.tscn"),
		},
	7:
		{
			3: preload("res://tileset/test/Prefab_7x3.tscn"),
		},
	8:
		{
			3: preload("res://tileset/test/Prefab_8x3.tscn"),
		},
	}

var spawn_position:Vector3
var map: GridMap

var position_walls := Array()
var position_doors := Array()
var position_doors_insertions := Array()
var position_start := Array()
var position_end := Array()
var position_left_ladders := Array()
var position_right_ladders := Array()

var rooms_areas := Dictionary()
var starting_room : Rect2
var ending_room : Rect2
var pathfinding := AStar.new()
var rnd := RandomNumberGenerator.new()
var seed_counter:int = 1

var label := Label.new()
var f:Font = label.get_font("")

func _ready():
	rnd.seed = map_seed
	gen_graph()

func _input(event):
	if event is InputEventKey and not event.is_pressed():
		if event.scancode == KEY_8:
			clear_console()
			gen_graph()
		if event.scancode == KEY_ENTER:
			_desired_seed_counter += DESIRED_SEED_STEP_COUNTER
			clear_console()
			gen_graph()
		if event.scancode == KEY_0:
			clear_console()
			for point in pathfinding.get_points():
				for connection in pathfinding.get_point_connections(point):
					print(str(point) + " -> " + str(connection))


func gen_graph():
	_clear_all()
	
	var rooms_locations = _generate_rooms()
	pathfinding = _generate_graph(rooms_locations.keys())
	var distantest:Array = _get_distantest_rooms(rooms_locations)
	starting_room = distantest[0]
	ending_room = distantest[1]
	spawn_position = get_middle(starting_room) * TILE_SIZE
	rooms_areas = _reorder_rooms(rooms_locations)
	update()
	emit_signal("graph_gen_finnished")
	_fill_the_map()
	_write_rooms_on_map()
		gen_graph()
	
	emit_signal("dungeon_generated")


func _generate_rooms() -> Dictionary:
	var rooms := Dictionary()
	for i in range(number_of_rooms):
		var room:Rect2
		var collide:bool = true
		while (collide):
			collide = false
			room = _create_room()
			for other in rooms.values():
				if room.intersects(other):
					collide = true
			
			if not collide:
				rooms[get_middle(room)] = room
	return rooms

func _create_room() -> Rect2:
	var width:int = (2 * room_margin + min_room_width + rnd.randi() % (max_room_width + 1 - min_room_width))
	var height:int = (2 * room_margin + min_room_height + rnd.randi() % (max_room_height + 1 - min_room_height))
	var x:int = rnd.randi() % (map_width - width)
	var y:int = rnd.randi() % (map_height - height)
	var pos := Vector2(floor(x), floor(y))
	var size := Vector2(width, height)
	return Rect2(pos, size)

func _get_room_rectangle(area: Rect2) -> Rect2:
	return area.grow(- room_margin)

func _generate_graph(locations: Array) -> AStar:
	var astar := AStar.new()
	astar.add_point(astar.get_available_point_id(), locations.pop_front())
	while locations:
		var current_position:Vector3
		var closest_position:Vector3
		var min_distance = INF
		
		for point in astar.get_points():
			var pos:Vector3 = astar.get_point_position(point)
			for otherPos in locations:
				var dist = pos.distance_to(otherPos)
				if dist < min_distance:
					min_distance = dist
					current_position = pos
					closest_position = otherPos
					
		var point:int = astar.get_available_point_id()
		astar.add_point(point, closest_position)
		astar.connect_points(astar.get_closest_point(current_position), point)
		locations.erase(closest_position)
	return astar

func _get_distantest_rooms(rooms_locations: Dictionary) -> Array:
	var result := Array()
	var a1 :Rect2
	var a2 :Rect2
	var distanceMax = 0
	var roomsBetweenMax = 0
	for area in rooms_locations.values():
		var middleArea = get_middle(area)
		var point = pathfinding.get_closest_point(middleArea)
		for otherArea in rooms_locations.values():
			if area != otherArea:
				var middleOther = get_middle(otherArea)
				var otherPoint = pathfinding.get_closest_point(middleOther)
				var path = pathfinding.get_id_path(point, otherPoint)
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
					a2 = otherArea
					distanceMax = distance
	
	result.append(a1)
	result.append(a2)
	return result

func _reorder_rooms(rooms_locations: Dictionary) -> Dictionary:
	var reordered := Dictionary()
	var startingPoint:int = pathfinding.get_closest_point(get_middle(starting_room))
	var endingPoint:int = pathfinding.get_closest_point(get_middle(ending_room))
	var path:PoolIntArray = pathfinding.get_id_path(endingPoint, startingPoint)
	
	for pathPoint in path:
		var pos:Vector3 = pathfinding.get_point_position(pathPoint)
		reordered[pathPoint] = rooms_locations[pos]
		
		for point in pathfinding.get_point_connections(pathPoint):
			_insert_child_rooms(point, reordered, rooms_locations, path)
	
	return reordered

func _insert_child_rooms(point: int, reordered: Dictionary, rooms_locations: Dictionary, path: PoolIntArray):
	for connection in pathfinding.get_point_connections(point):
		if not connection in path:
			if not connection in reordered.keys():
				var pos:Vector3 = pathfinding.get_point_position(connection)
				reordered[connection] = rooms_locations[pos]
				_insert_child_rooms(connection, reordered, rooms_locations, path)


func _fill_the_map():
	for x in range(map_width):
		for y in range(map_height):
			var v = Vector3(x, y, 0)
			_apply_tile_on_tilemap(v, eTilesType.Wall)


func _write_rooms_on_map():
	for area in rooms_areas.values():
		var room = _get_room_rectangle(area)
		var w:Dictionary = ROOM_PREFAB.get(int(room.size.x))
		if w:
			var h = w.get(int(room.size.y))
			if h:
				var prefab:Spatial = h.instance()			
				prefab.translate(get_middle(room) * TILE_SIZE - Vector3(1, 1, 0))
				prefab.add_to_group("MapElements")
				add_child(prefab)
		
		var left = room.position.x
		var right = left + room.size.x
		var top = room.position.y
		var bottom = top + room.size.y
		var z = 0
		for x in range(left, right):
			for y in range(top, bottom):
				var v = Vector3(x, y, z)
				_apply_tile_on_tilemap(v, eTilesType.Empty)


func _write_corridors_on_map():
	var rooms_done = []
	
	for point in rooms_areas.keys():
		for connection in pathfinding.get_point_connections(point):
			if not connection in rooms_done:
				if PRINT_ROOMS_TRAVEL: print(str(point) + " -> " + str(connection))
				var posRoom1 = pathfinding.get_point_position(point)
				var posRoom2 = pathfinding.get_point_position(connection)
				var start = _get_door_location(_get_room_rectangle(rooms_areas[point]), posRoom2)
				var end = _get_door_location(_get_room_rectangle(rooms_areas[connection]), posRoom1)
				_dig_path(start, end, FORCE_START_DOOR, FORCE_END_DOOR)
		
		rooms_done.append(point)


func _dig_path(start: Dictionary, end: Dictionary, doorOnStart: bool = false, doorOnEnd: bool = false):
	if start.size() > 0 && end.size() > 0:
		var startDir = start.keys()[0]
		var endDir = end.keys()[0]
		var startPos = to_vector3(start.values()[0])
		var endPos = to_vector3(end.values()[0])
		
		var horizontalStart = (startDir == eDirection.Left || startDir == eDirection.Right)
		var horizontalEnd = (endDir == eDirection.Left || endDir == eDirection.Right)
		var verticalStart = (startDir == eDirection.Top || startDir == eDirection.Bottom)
		var verticalEnd = (endDir == eDirection.Top || endDir == eDirection.Bottom)
		var horizontalPath = (horizontalStart && horizontalEnd)
		var verticalPath = (verticalStart && verticalEnd)
		
		if PRINT_DOOR_LOCATION:
			var startPoint = pathfinding.get_closest_point(startPos)
			var endPoint = pathfinding.get_closest_point(endPos)
			print(str(startPoint) + " -> " + str(endPoint) + " = " + str(start) + " -> " + str(end))
			if startPoint == 10 :
				startPoint=startPoint
		if horizontalPath:		# Horizontal direction only
			_dig_horizontally(startPos, endPos, doorOnStart, doorOnEnd)
		elif verticalPath:		# Vertical direction only
			_dig_vertically(startPos, endPos, doorOnStart, doorOnEnd)
		else:					# Mixed directions
			if horizontalStart && verticalEnd:
				_dig_mixed_directions(startPos, endPos, doorOnStart, doorOnEnd)
			elif verticalStart && horizontalEnd:
				_dig_mixed_directions(endPos, startPos, doorOnEnd, doorOnStart)
		
		if DEBUG:
			_apply_tile_on_tilemap(to_vector3(start.values()[0]), eTilesType.DoorInsertion)
			_apply_tile_on_tilemap(to_vector3(end.values()[0]), eTilesType.DoorInsertion)
	
	else:
		if PRINT_REFUSED_DUNGEON:
			print("Connections impossible, regénération de donjon : ")
			print("map_seed = " + str(map_seed))
			print("seed_counter = " + str(seed_counter))
			print("get_seed = " + str(rnd.seed))
		gen_graph()


func _first_step_is_on_right(dif: Vector3, dir: Vector2) -> bool:
	var yIndex = int(abs(dif.y))
	if PRINT_LADDER:
		print("yIndex = " + str(yIndex) + " Dif = " + str(dif) + " Dir = " + str(dir))
	if dir.y > 0:
		return dir.x > 0
	else:
		if dir.x < 0:
			return yIndex % 2 == 1
		else:
			return yIndex % 2 == 0


func _dig_horizontally(startPos: Vector3, endPos: Vector3, doorOnStart: bool, doorOnEnd: bool):
	startPos = vector3_floor(startPos)
	endPos = vector3_floor(endPos)
	var dif = vector3_floor(endPos - startPos)
	var middlePos = vector3_round(startPos + (dif / 2))
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	for x in range(startPos.x + step.x, endPos.x, step.x):
		var v : Vector3
		if x < middlePos.x && step.x > 0 || x > middlePos.x && step.x < 0:
			v = Vector3(x, startPos.y, 0)
		else:
			v = Vector3(x, endPos.y, 0)
		if doorOnStart && x == startPos.x + step.x ||doorOnEnd && x == endPos.x - step.x:
			_apply_tile_on_tilemap(v, eTilesType.Door)
		else:
			_apply_tile_on_tilemap(v, eTilesType.Empty)
	
	var toggleRight:bool = _first_step_is_on_right(dif, step)
	for y in range(startPos.y, endPos.y + step.y, step.y):
		var v = Vector3(middlePos.x, y, 0)
		var isEndOfLadder:bool = false
		if step.y > 0:
			isEndOfLadder = y == int(endPos.y)
		else:
			isEndOfLadder = y == int(startPos.y)
		if not isEndOfLadder:
			if toggleRight:
				_apply_tile_on_tilemap(v, eTilesType.RightLadder)
			else:
				_apply_tile_on_tilemap(v, eTilesType.LeftLadder)
			toggleRight = not toggleRight
		else:
			_apply_tile_on_tilemap(v, eTilesType.Empty)


func _dig_vertically(startPos: Vector3, endPos: Vector3, doorOnStart: bool, doorOnEnd: bool):
	startPos = vector3_floor(startPos)
	endPos = vector3_floor(endPos)
	var dif = vector3_floor(endPos - startPos)
	var middlePos = vector3_round(startPos + (dif / 2))
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	var top:Vector3 = endPos
	var bottom:Vector3 = startPos
	var doorOnTop = doorOnEnd
	var doorOnBottom = doorOnStart
	
	if step.y < 0:
		top = startPos
		bottom = endPos
		doorOnTop = doorOnStart
		doorOnBottom = doorOnEnd
		step = - step
	
	for x in range(bottom.x, top.x + step.x, step.x):
		var v = Vector3(x, middlePos.y, 0)
		_apply_tile_on_tilemap(v, eTilesType.Empty)
	
	var delta:Vector3 = vector3_floor(bottom - middlePos)
		
	var toggleRight:bool = _first_step_is_on_right(delta, step)
	
	for y in range(bottom.y + step.y, top.y, step.y):
		var v : Vector3
		if y < middlePos.y && step.y > 0 || y > middlePos.y && step.y < 0:
			v = Vector3(bottom.x, y, 0)
		else:
			v = Vector3(top.x, y, 0)
			
			if y == middlePos.y && step.x != 0:
				delta = vector3_floor(middlePos - top)
				toggleRight = _first_step_is_on_right(delta, step)
				
		if doorOnBottom && y == bottom.y + step.y || doorOnTop && y == top.y - step.y:
			_apply_tile_on_tilemap(v, eTilesType.Door)
			toggleRight = not toggleRight
		else:
			var isEndOfLadder:bool = false
			if step.y > 0:
				isEndOfLadder = y == int(top.y) || y == int(top.y - step.y)
			elif step.y == 0:
				isEndOfLadder = true
			
			if not isEndOfLadder:
				if toggleRight:
					_apply_tile_on_tilemap(v, eTilesType.RightLadder)
				else:
					_apply_tile_on_tilemap(v, eTilesType.LeftLadder)
				toggleRight = not toggleRight
			else:
				_apply_tile_on_tilemap(v, eTilesType.Empty)


func _dig_mixed_directions(horizontalPos: Vector3, verticalPos: Vector3, doorOnHorizontal: bool, doorOnVertical: bool):
	horizontalPos = vector3_floor(horizontalPos)
	verticalPos = vector3_floor(verticalPos)
	var dif = vector3_floor(verticalPos - horizontalPos)
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	for x in range(horizontalPos.x, verticalPos.x, step.x):
		var v = Vector3(x, horizontalPos.y, 0)
		if doorOnHorizontal && x == horizontalPos.x + step.x:
			_apply_tile_on_tilemap(v, eTilesType.Door)
		else:
			_apply_tile_on_tilemap(v, eTilesType.Empty)
	
	var toggleRight:bool = _first_step_is_on_right(dif, step)
	for y in range(horizontalPos.y, verticalPos.y, step.y):
		var v = Vector3(verticalPos.x, y, 0)
		if doorOnVertical && y == verticalPos.y - step.y:
			_apply_tile_on_tilemap(v, eTilesType.Door)
		else:
			var isEndOfLadder:bool = false
			if step.y > 0:
				isEndOfLadder = y == int(verticalPos.y)
			else:
				isEndOfLadder = y == int(horizontalPos.y)
				
			if not isEndOfLadder:
				if toggleRight:
					_apply_tile_on_tilemap(v, eTilesType.RightLadder)
				else:
					_apply_tile_on_tilemap(v, eTilesType.LeftLadder)
				toggleRight = not toggleRight
			else:
				_apply_tile_on_tilemap(v, eTilesType.Empty)


func _get_door_location(rect: Rect2, point: Vector3) -> Dictionary:
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


func _translate_multimesh(multi_mesh_inst:MultiMeshInstance, positions:Array, tileType: int, basis: Basis):
	multi_mesh_inst.multimesh.instance_count = positions.size()
	for i in range(positions.size()):
		var pos:Vector3 = positions[i]
		multi_mesh_inst.multimesh.set_instance_transform(i, Transform(basis,  pos))
		if not DISABLE_COLLISION:
			var static_body = STATIC_BODIES.get(tileType)
			if static_body:
				var body = static_body.instance()
				body.translate(pos)
				#body.add_group("MapElements")
				add_child(body)


func _generate_multimesh():
	var wall:MultiMeshInstance = $"../Tiles/Wall"
	var door:MultiMeshInstance = $"../Tiles/Door"
	var doorInsertion:MultiMeshInstance = $"../Tiles/DoorInsertion"
	var start:MultiMeshInstance = $"../Tiles/Start"
	var end:MultiMeshInstance = $"../Tiles/End"
	var leftLadder:MultiMeshInstance = $"../Tiles/LeftLadder"
	var rightLadder:MultiMeshInstance = $"../Tiles/RightLadder"
	
	var basis = Basis()
	
	_translate_multimesh(wall, position_walls, eTilesType.Wall, basis)
	_translate_multimesh(door, position_doors, eTilesType.Door, basis)
	_translate_multimesh(doorInsertion, position_doors_insertions, eTilesType.DoorInsertion, basis)
	_translate_multimesh(start, position_start, eTilesType.Start, basis)
	_translate_multimesh(end, position_end, eTilesType.End, basis)
	_translate_multimesh(leftLadder, position_left_ladders, eTilesType.LeftLadder, basis)
	_translate_multimesh(rightLadder, position_right_ladders, eTilesType.RightLadder, basis)


func _apply_tile_on_tilemap(pos: Vector3, tileType: int):
	if map:
		map.set_cell_item(pos.x, pos.y, pos.z, tileType)
	else:
		var v :Vector3 = pos * TILE_SIZE
		_delete_tile_at(v)
		match tileType:
			eTilesType.Wall:
				position_walls.append(v)
			eTilesType.Door:
				position_doors.append(v)
			eTilesType.DoorInsertion:
				if DEBUG:
					position_doors_insertions.append(v)
			eTilesType.Start:
				if DEBUG:
					position_start.append(v)
			eTilesType.End:
				if DEBUG:
					position_end.append(v)
			eTilesType.LeftLadder:
				position_left_ladders.append(v)
			eTilesType.RightLadder:
				position_right_ladders.append(v)


func _delete_tile_at(pos:Vector3):
	position_walls.erase(pos)
	position_doors.erase(pos)
	position_left_ladders.erase(pos)
	position_right_ladders.erase(pos)
	if DEBUG:
		position_doors_insertions.erase(pos)
		position_start.erase(pos)
		position_end.erase(pos)


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

func _clear_all():
	clear_console()
	var MapElements = get_tree().get_nodes_in_group("MapElements")
	for element in MapElements:
	    element.queue_free()
	
	position_walls.clear()
	position_doors.clear()
	position_doors_insertions.clear()
	position_start.clear()
	position_end.clear()
	position_left_ladders.clear()
	position_right_ladders.clear()
	rooms_areas.clear()
	pathfinding = null


func clear_console():
	for i in range(5):
		print(" ")
	"""
	var escape := PoolByteArray([0x1b]).get_string_from_ascii()
	print(escape + "[2J" + escape + "[;H")
	"""