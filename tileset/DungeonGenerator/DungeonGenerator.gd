extends Node2D

export var tile_size = 2
export var room_margin = 1
export(int, 3, 13) var number_of_rooms = 5 
export var map_width = 40
export var map_height = 25
export var min_room_size = 5
export var max_room_size = 10

signal graph_gen_finnished

enum eTilesType { Empty = -1, Floor = 0, Wall = 1 }

var rooms_areas = Array()
var pathfinding := AStar.new()


func _ready():
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
	var width = (min_room_size + randi() % (max_room_size - min_room_size)) * tile_size
	var height = (min_room_size + randi() % (max_room_size - min_room_size)) * tile_size
	var x = randi() % (map_width * tile_size - width)
	var y = randi() % (map_height * tile_size - height)
	var pos = Vector2(x - (x % tile_size), y - (y % tile_size))
	var size = Vector2(width, height)
	return Rect2(pos, size)

func get_room_rectangle(area: Rect2) -> Rect2:
	return area.grow(- room_margin * tile_size)
	#var margin = Vector2.ONE * room_margin * tile_size
	#return Rect2(area.position + margin, area.size - margin * 2)

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
	write_floor_on_map(map)
	write_rooms_on_map(map)
	write_corridors_on_map(map)

func write_floor_on_map(map: GridMap):
	for x in range(map_width * tile_size):
		for z in range(map_height * tile_size):
			map.set_cell_item(x, -1, z, eTilesType.Floor)

func write_rooms_on_map(map: GridMap):
	for area in rooms_areas:
		var room = get_room_rectangle(area)
		var left = room.position.x
		var right = left + room.size.x
		var top = room.position.y
		var bottom = top + room.size.y
		for x in range(left, right + 1):
			for z in range(top, bottom + 1):
				map.set_cell_item(x, 0, z, 1)	# room floor
				if x == left or x == right or z == top or z == bottom:
					map.set_cell_item(x, 1, z, eTilesType.Wall)	# room walls
		

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
	var zStep = sign(end.z - start.z)
	if xStep == 0: xStep = pow(-1, randi() % 2)
	if zStep == 0: zStep = pow(-1, randi() % 2)
	var x_to_z = start		# Direction horizontal and vertical
	var z_to_x = end		# Direction vertical and horizontal
	if randi() % 2 == 0:
		z_to_x = start
		x_to_z = end
	for x in range(start.x, end.x + xStep, xStep): # + xStep * 2, xStep):
		map.set_cell_item(x, 1, x_to_z.z, eTilesType.Empty)
		#map.set_cell_item(x, 0, x_to_z.z - zStep, eTilesType.Wall)
		map.set_cell_item(x, 0, x_to_z.z, eTilesType.Wall)
		#map.set_cell_item(x, 0, x_to_z.z + zStep, eTilesType.Wall)
	for z in range(start.z, end.z + zStep, zStep): # + zStep * 2, zStep):
		map.set_cell_item(z_to_x.x, 1, z, eTilesType.Empty)
		#map.set_cell_item(z_to_x.x - xStep, 0, z, eTilesType.Wall)
		map.set_cell_item(z_to_x.x, 0, z, eTilesType.Wall)
		#map.set_cell_item(z_to_x.x + xStep, 0, z, eTilesType.Wall)


func to_vector3(v: Vector2, y :int = 0) -> Vector3:
	return Vector3(v.x, y, v.y)
	
func to_vector2(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)

func get_middle(r: Rect2) -> Vector3:
	return to_vector3(r.position + (r.size / 2))

func _draw():
	for area in rooms_areas:
		draw_rect(area, Color.white, false)						# draw area
		draw_rect(get_room_rectangle(area), Color.red, true)	# draw room (without margin)
	draw_path(pathfinding)

func draw_path(path: AStar):
	if path:
		for point in path.get_points():
			for edges in path.get_point_connections(point):
				var pointPosition = path.get_point_position(point)
				var edgePosition = path.get_point_position(edges)
				draw_line(to_vector2(pointPosition), to_vector2(edgePosition), Color.yellow)