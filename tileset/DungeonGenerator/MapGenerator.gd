extends Spatial

signal request_new_dungeon
signal dungeon_gen_finished

# Parameters
var rnd:RandomNumberGenerator
var _graph_generator:GraphGenerator
var mob_chance_corridors:float


var _geometry:GeometryHelper = GeometryHelper.new()
var _resourceMgr:DungeonRessource = DungeonRessource.new()

var _eTilesType := _resourceMgr.eTilesType
var _eDirection := DirectionHelper.eDirection
var _pathfinding:AStar
var _rooms_areas:Dictionary

var use_gridmap:bool
var tile_size:int
var spawn_position:Vector3

##################### DEBUG AREA #####################
const DEBUG:bool = false
const FORCE_START_DOOR:bool = false
const FORCE_END_DOOR:bool = false
const DISABLE_COLLISION:bool = false
const DRAW_ROOMS_INDEX:bool = false
const PRINT_REFUSED_DUNGEON:bool = true
const PRINT_LADDER:bool = false
const PRINT_ROOMS_TRAVEL:bool = false
const PRINT_DOOR_LOCATION:bool = false
const DESIRED_SEED_STEP_COUNTER:int = 1
var _desired_seed_counter:int = 0
var _seed_counter:int = 1
##################### DEBUG AREA #####################

func _ready():
	var tiles:Array = get_tree().get_nodes_in_group("Tiles")
	for tile in tiles:
		tile.connect("on_translate", self, "_on_tile_translate")


func _on_tile_translate(source:MultiMeshInstance, pos:Vector3):
	if not DISABLE_COLLISION:
		var static_body:Spatial = _resourceMgr.STATIC_BODIES.get(_eTilesType[source.name])
		if static_body:
			var body:Spatial = static_body.instance()
			body.translate(pos)
			body.add_to_group("MapElements")
			add_child(body)


func gen_dungeon(graph_generator:GraphGenerator):
	clear_all()
	_graph_generator = graph_generator
	_pathfinding = _graph_generator.pathfinding
	_rooms_areas = _graph_generator.rooms_areas
	var startMiddle:Vector3 = _geometry.to_vector3(_graph_generator.starting_room.get_middle())
	spawn_position = startMiddle * tile_size
	_fill_the_map()
	_write_rooms_on_map()
	if _write_corridors_on_map():
		emit_signal("request_new_dungeon")
	else:
		if DEBUG:
			var endMiddle:Vector3 = _geometry.to_vector3(_graph_generator.ending_room.get_middle())
			_apply_tile_on_tilemap(startMiddle, _eTilesType.Start)
			_apply_tile_on_tilemap(endMiddle, _eTilesType.End)
		
		if not use_gridmap:
			var tiles = get_tree().get_nodes_in_group("Tiles")
			for tile in tiles:
			    tile.translate_all()
		
		_seed_counter += 1
		if DEBUG && _seed_counter < _desired_seed_counter:
			emit_signal("request_new_dungeon")
		
		emit_signal("dungeon_gen_finished")


func _fill_the_map():
	for x in range(_graph_generator.map_width):
		for y in range(_graph_generator.map_height):
			var v = Vector3(x, y, 0)
			_apply_tile_on_tilemap(v, _eTilesType.Wall)


func _write_rooms_on_map():
	for room in _graph_generator.rooms_areas.values():
		var room_rect:Rect2 = room.get_room_rect()
		var w:Dictionary = _resourceMgr.ROOM_PREFAB.get(int(room_rect.size.x))
		if w:
			var h = w.get(int(room_rect.size.y))
			if h:
				var prefab:Spatial = h.instance()
				prefab.translate(_geometry.to_vector3(room.get_middle()) * tile_size - Vector3(1, 1, 0))
				prefab.add_to_group("MapElements")
				add_child(prefab)
		
		var left = room_rect.position.x
		var right = left + room_rect.size.x
		var top = room_rect.position.y
		var bottom = top + room_rect.size.y
		var z = 0
		for x in range(left, right):
			for y in range(top, bottom):
				var v = Vector3(x, y, z)
				_apply_tile_on_tilemap(v, _eTilesType.Empty)


func _write_corridors_on_map() -> bool:	# Return true on error
	var rooms_done := Array()
	
	for point in _graph_generator.rooms_areas.keys():
		for connection in _pathfinding.get_point_connections(point):
			if not connection in rooms_done:
				if PRINT_ROOMS_TRAVEL: print(str(point) + " -> " + str(connection))
				var posRoom1:Vector3 = _pathfinding.get_point_position(point)
				var posRoom2:Vector3 = _pathfinding.get_point_position(connection)
				var start = _rooms_areas[point].gen_door_location(_geometry.to_vector2(posRoom2))
				var end = _rooms_areas[connection].gen_door_location(_geometry.to_vector2(posRoom1))
				var error:bool = _dig_path(start, end, FORCE_START_DOOR, FORCE_END_DOOR)
				if error:
					return error
		rooms_done.append(point)
	return false


func _dig_path(start: Dictionary, end: Dictionary, doorOnStart: bool = false, doorOnEnd: bool = false) -> bool:	# Return true on error
	if start.size() > 0 && end.size() > 0:
		var startDir = start.keys()[0]
		var endDir = end.keys()[0]
		var startPos:Vector3 = _geometry.to_vector3(start.values()[0])
		var endPos:Vector3 = _geometry.to_vector3(end.values()[0])
		
		var horizontalStart = (startDir == _eDirection.Left || startDir == _eDirection.Right)
		var horizontalEnd = (endDir == _eDirection.Left || endDir == _eDirection.Right)
		var verticalStart = (startDir == _eDirection.Top || startDir == _eDirection.Bottom)
		var verticalEnd = (endDir == _eDirection.Top || endDir == _eDirection.Bottom)
		var horizontalPath = (horizontalStart && horizontalEnd)
		var verticalPath = (verticalStart && verticalEnd)
		
		var putMobSpawn:bool = rnd.randf() > 1 - mob_chance_corridors
		
		if PRINT_DOOR_LOCATION:
			var startPoint = _pathfinding.get_closest_point(startPos)
			var endPoint = _pathfinding.get_closest_point(endPos)
			print(str(startPoint) + " -> " + str(endPoint) + " = " + str(start) + " -> " + str(end))
			if startPoint == 10 :
				startPoint=startPoint
		if horizontalPath:		# Horizontal direction only
			_dig_horizontally(startPos, endPos, putMobSpawn, doorOnStart, doorOnEnd)
		elif verticalPath:		# Vertical direction only
			_dig_vertically(startPos, endPos, putMobSpawn, doorOnStart, doorOnEnd)
		else:					# Mixed directions
			if horizontalStart && verticalEnd:
				_dig_mixed_directions(startPos, endPos, putMobSpawn, doorOnStart, doorOnEnd)
			elif verticalStart && horizontalEnd:
				_dig_mixed_directions(endPos, startPos, putMobSpawn, doorOnEnd, doorOnStart)
		
		if DEBUG:
			_apply_tile_on_tilemap(_geometry.to_vector3(start.values()[0]), _eTilesType.DoorInsertion)
			_apply_tile_on_tilemap(_geometry.to_vector3(end.values()[0]), _eTilesType.DoorInsertion)
		
		return false
	else:
		if PRINT_REFUSED_DUNGEON:
			print("Connections impossible, regénération de donjon : ")
			print("get_seed = " + str(rnd.seed))
		return true


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


func _dig_horizontally(startPos: Vector3, endPos: Vector3, mobSpawn: bool, doorOnStart: bool, doorOnEnd: bool):
	startPos = _geometry.vector3_floor(startPos)
	endPos = _geometry.vector3_floor(endPos)
	var dif = _geometry.vector3_floor(endPos - startPos)
	var middlePos = _geometry.vector3_round(startPos + (dif / 2))
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	if mobSpawn:
		_add_mob_spawn(middlePos)
	
	for x in range(startPos.x + step.x, endPos.x, step.x):
		var v : Vector3
		if x < middlePos.x && step.x > 0 || x > middlePos.x && step.x < 0:
			v = Vector3(x, startPos.y, 0)
		else:
			v = Vector3(x, endPos.y, 0)
		if doorOnStart && x == startPos.x + step.x ||doorOnEnd && x == endPos.x - step.x:
			_apply_tile_on_tilemap(v, _eTilesType.Door)
		else:
			_apply_tile_on_tilemap(v, _eTilesType.Empty)
	
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
				_apply_tile_on_tilemap(v, _eTilesType.RightLadder)
			else:
				_apply_tile_on_tilemap(v, _eTilesType.LeftLadder)
			toggleRight = not toggleRight
		else:
			_apply_tile_on_tilemap(v, _eTilesType.Empty)


func _dig_vertically(startPos: Vector3, endPos: Vector3, mobSpawn: bool, doorOnStart: bool, doorOnEnd: bool):
	startPos = _geometry.vector3_floor(startPos)
	endPos = _geometry.vector3_floor(endPos)
	var dif = _geometry.vector3_floor(endPos - startPos)
	var middlePos = _geometry.vector3_round(startPos + (dif / 2))
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
	
	if mobSpawn:
		_add_mob_spawn(middlePos)
	
	for x in range(bottom.x, top.x + step.x, step.x):
		var v = Vector3(x, middlePos.y, 0)
		_apply_tile_on_tilemap(v, _eTilesType.Empty)
	
	var delta:Vector3 = _geometry.vector3_floor(bottom - middlePos)
		
	var toggleRight:bool = _first_step_is_on_right(delta, step)
	
	for y in range(bottom.y + step.y, top.y, step.y):
		var v : Vector3
		if y < middlePos.y && step.y > 0 || y > middlePos.y && step.y < 0:
			v = Vector3(bottom.x, y, 0)
		else:
			v = Vector3(top.x, y, 0)
			
			if y == middlePos.y && step.x != 0:
				delta = _geometry.vector3_floor(middlePos - top)
				toggleRight = _first_step_is_on_right(delta, step)
				
		if doorOnBottom && y == bottom.y + step.y || doorOnTop && y == top.y - step.y:
			_apply_tile_on_tilemap(v, _eTilesType.Door)
			toggleRight = not toggleRight
		else:
			var isEndOfLadder:bool = false
			if step.y > 0:
				isEndOfLadder = y == int(top.y) || y == int(top.y - step.y)
			elif step.y == 0:
				isEndOfLadder = true
			
			if not isEndOfLadder:
				if toggleRight:
					_apply_tile_on_tilemap(v, _eTilesType.RightLadder)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.LeftLadder)
				toggleRight = not toggleRight
			else:
				_apply_tile_on_tilemap(v, _eTilesType.Empty)


func _dig_mixed_directions(horizontalPos: Vector3, verticalPos: Vector3, mobSpawn: bool, doorOnHorizontal: bool, doorOnVertical: bool):
	horizontalPos = _geometry.vector3_floor(horizontalPos)
	verticalPos = _geometry.vector3_floor(verticalPos)
	var dif = _geometry.vector3_floor(verticalPos - horizontalPos)
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	if mobSpawn:
		_add_mob_spawn(Vector3(verticalPos.x, horizontalPos.y, 0))
	
	for x in range(horizontalPos.x, verticalPos.x, step.x):
		var v = Vector3(x, horizontalPos.y, 0)
		if doorOnHorizontal && x == horizontalPos.x + step.x:
			_apply_tile_on_tilemap(v, _eTilesType.Door)
		else:
			_apply_tile_on_tilemap(v, _eTilesType.Empty)
	
	var toggleRight:bool = _first_step_is_on_right(dif, step)
	for y in range(horizontalPos.y, verticalPos.y, step.y):
		var v = Vector3(verticalPos.x, y, 0)
		if doorOnVertical && y == verticalPos.y - step.y:
			_apply_tile_on_tilemap(v, _eTilesType.Door)
		else:
			var isEndOfLadder:bool = false
			if step.y > 0:
				isEndOfLadder = y == int(verticalPos.y)
			else:
				isEndOfLadder = y == int(horizontalPos.y)
				
			if not isEndOfLadder:
				if toggleRight:
					_apply_tile_on_tilemap(v, _eTilesType.RightLadder)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.LeftLadder)
				toggleRight = not toggleRight
			else:
				_apply_tile_on_tilemap(v, _eTilesType.Empty)

func _add_mob_spawn(pos:Vector3):
	var mob_resources = _resourceMgr.MOB_RESOURCES
	var variant = randi() % mob_resources.size()
	var mob_resource = mob_resources[variant]
	if mob_resource:
		var mob = mob_resource.instance()
		mob.translate(pos * tile_size)
		mob.add_to_group("MapElements")
		add_child(mob)


func _apply_tile_on_tilemap(pos: Vector3, tileType: int):
	if use_gridmap:
		$GridMap.set_cell_item(pos.x, pos.y, pos.z, tileType)
	else:
		var v :Vector3 = pos * tile_size
		
		$Wall.delete_tile_at(v)
		match tileType:
			_eTilesType.Wall:
				$Wall.insert(v)
			_eTilesType.Door:
				$Door.insert(v)
			_eTilesType.LeftLadder:
				$LeftLadder.insert(v)
			_eTilesType.RightLadder:
				$RightLadder.insert(v)
			_eTilesType.DoorInsertion:
				if DEBUG:
					$DoorInsertion.insert(v)
			_eTilesType.Start:
				if DEBUG:
					$Start.insert(v)
			_eTilesType.End:
				if DEBUG:
					$End.insert(v)


func clear_all():
	var mapElements = get_tree().get_nodes_in_group("MapElements")
	for element in mapElements:
		element.free()
		print("remove map element")
	
	var tiles = get_tree().get_nodes_in_group("Tiles")
	for tile in tiles:
	    tile.clear()