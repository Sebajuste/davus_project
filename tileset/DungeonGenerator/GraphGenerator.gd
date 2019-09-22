class_name GraphGenerator

signal graph_gen_finished

# Parameters
var rnd:RandomNumberGenerator
var room_margin:int
var number_of_rooms:int
var number_of_keys:int
var map_width:int
var map_height:int
var min_room_width:int
var max_room_width:int
var min_room_height:int
var max_room_height:int
var map_seed:int

var _geometry := GeometryHelper.new()
var _room_factory := Room

var pathfinding := AStar.new()
var rooms_areas := Dictionary()
var starting_room:Room
var ending_room:Room

func gen_graph():
	clear_all()
	
	var rooms_locations:Dictionary = _generate_rooms()
	pathfinding = _generate_astar(rooms_locations.keys())
	_calculate_distantest_rooms(rooms_locations)
	var startMiddle:Vector3 = _geometry.to_vector3(starting_room.get_middle())
	rooms_areas = _reorder_rooms(rooms_locations)
	emit_signal("graph_gen_finished")


func _generate_rooms() -> Dictionary:	# <middlePosition:Vector3, Room>
	var rooms := Dictionary()
	for i in range(number_of_rooms):
		var collide:bool = true
		while (collide):
			collide = false
			var room = Room.new(rnd,
				min_room_width, max_room_width, 
				min_room_height, max_room_height, 
				map_width, map_height, room_margin
				)
			for other in rooms.values():
				if room.area.intersects(other.area):
					collide = true
			
			if not collide:
				var middle:Vector3 = _geometry.to_vector3(room.get_middle())
				rooms[middle] = room
	return rooms


func _generate_astar(locations: Array) -> AStar:
	var astar := AStar.new()
	astar.add_point(astar.get_available_point_id(), locations.pop_front())
	while locations:
		var current_position:Vector3
		var closest_position:Vector3
		var min_distance:float = INF
		
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


func _calculate_distantest_rooms(rooms_locations: Dictionary):
	var a1:Room
	var a2:Room
	var distanceMax = 0
	var roomsBetweenMax = 0
	for middle in rooms_locations.keys():
		var area = rooms_locations[middle]
		var point = pathfinding.get_closest_point(middle)
		for otherMiddle in rooms_locations.keys():
			var otherArea = rooms_locations[otherMiddle]
			if area != otherArea:
				var otherPoint = pathfinding.get_closest_point(otherMiddle)
				var path = pathfinding.get_id_path(point, otherPoint)
				var roomsBetween = path.size()
				var isDistantest = false
				var distance = middle.distance_to(otherMiddle)
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
	starting_room = a1
	ending_room = a2


func _reorder_rooms(rooms_locations: Dictionary) -> Dictionary:
	var reordered := Dictionary()
	
	var startMiddle:Vector3 = _geometry.to_vector3(starting_room.get_middle())
	var startingPoint:int = pathfinding.get_closest_point(startMiddle)
	
	var endMiddle:Vector3 = _geometry.to_vector3(ending_room.get_middle())
	var endingPoint:int = pathfinding.get_closest_point(endMiddle)
	
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


func clear_all():
	rooms_areas.clear()
	pathfinding = null