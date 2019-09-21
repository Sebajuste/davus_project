class_name Room

var area:Rect2
var room_margin:int
var output_locations:Dictionary

var geometry:GeometryHelper = GeometryHelper.new()
var direction:DirectionHelper = DirectionHelper.new()

func _init(rnd:RandomNumberGenerator, min_room_width:int, max_room_width:int, min_room_height:int, max_room_height:int, map_width:int, map_height:int, margin:int = 2):
	var width:int = (2 * margin + min_room_width + rnd.randi() % (max_room_width + 1 - min_room_width))
	var height:int = (2 * margin + min_room_height + rnd.randi() % (max_room_height + 1 - min_room_height))
	var x:int = rnd.randi() % (map_width - width)
	var y:int = rnd.randi() % (map_height - height)
	var pos := Vector2(floor(x), floor(y))
	var size := Vector2(width, height)
	area = Rect2(pos, size)
	room_margin = margin

func get_room_rect() -> Rect2:
	return area.grow(- room_margin)

func get_middle() -> Vector2:
	return geometry.get_middle(area)

func gen_door_location(point: Vector2) -> Dictionary:
	var room_rect = get_room_rect()
	var middle = get_middle()
	var topRight = room_rect.position + (room_rect.size * Vector2.RIGHT)
	var bottomLeft = room_rect.position + (room_rect.size * Vector2.DOWN)
	var bottomRight = room_rect.position + room_rect.size
	var dir = (point - middle).normalized()
	var output = Dictionary()
	output[direction.eDirection.Top] = geometry.get_line_intersection(room_rect.position, topRight, middle, point)
	output[direction.eDirection.Bottom] = geometry.get_line_intersection(bottomLeft, bottomRight, middle, point) - dir
	output[direction.eDirection.Left] = geometry.get_line_intersection(room_rect.position, bottomLeft, middle, point)
	output[direction.eDirection.Right] = geometry.get_line_intersection(topRight, bottomRight, middle, point) - dir
	for d in output.keys():
		var intersection = output[d]
		if intersection == Vector2.INF:
			output.erase(d)
		else:
			output_locations[d] = output[d]
	return output