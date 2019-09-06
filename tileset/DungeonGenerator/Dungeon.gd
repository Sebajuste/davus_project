extends Node2D

export var number_of_rooms = 12
export var map_width = 600
export var map_height = 400
export var min_room_size = 50
export var max_room_size = 100

var rooms = Array()
var pathfinding


func _ready():
	gen_graph()

func _input(event):
	if event is InputEventKey and event.scancode == KEY_SPACE:
		gen_graph()

func gen_graph():
	rooms.clear()
	pathfinding = null
	var roomLocations = make_rooms()
	pathfinding = get_closest_room(roomLocations)
	number_of_rooms += 1

func make_rooms() -> Array:
	var locations = Array()
	for i in range(number_of_rooms):
		var room
		var collide = true
		while (collide):
			collide = false
			room = generate_room()
			for other in rooms:
				if room.intersects(other):
					collide = true
			
			if not collide:
				rooms.append(room)
				locations.append(to_vector3(room.position) + to_vector3(room.size / 2))
	
	return locations

func generate_room() -> Rect2:
	var pos = Vector2(randi() % map_width, randi() % map_height)
	var width = min_room_size + randi() % (max_room_size - min_room_size)
	var height = min_room_size + randi() % (max_room_size - min_room_size)
	var size = Vector2(width, height)
	return Rect2(pos, size)

func to_vector3(v: Vector2) -> Vector3:
	return Vector3(v.x, v.y, 0)
	
func to_vector2(v: Vector3) -> Vector2:
	return Vector2(v.x, v.y)

func get_closest_room(locations: Array) -> AStar:
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

func _process(delta):
	update()

func _draw():
	for r in rooms:
		draw_rect(r, Color.white, false)
	draw_path(pathfinding)


func draw_path(path: AStar):
	if path:
		for point in path.get_points():
			for edges in path.get_point_connections(point):
				var pointPosition = path.get_point_position(point)
				var edgePosition = path.get_point_position(edges)
				draw_line(to_vector2(pointPosition), to_vector2(edgePosition), Color.yellow)