extends Spatial

signal request_new_dungeon
signal dungeon_gen_finished(graph_generator)

# Parameters
var rnd:RandomNumberGenerator
var _graph_generator:GraphGenerator
var mob_chance_corridors:float
var min_nb_key:int
var key_occupation:float

########################################## A VIRER après debug.
var avirer = preload("res://tileset/test/MobSpawn.tscn")
##########################################

var _geometry:GeometryHelper = GeometryHelper.new()
var _resourceMgr:DungeonResource = DungeonResource.new()

var _eTilesType := _resourceMgr.eTilesType
var _eDirection := DirectionHelper.eDirection
var _pathfinding:AStar
var _rooms_areas:Dictionary		# <point, room>
var _currentDoorID:int = 0
var _pathRoomsCounter:int = 0
var _totalRoomsCounter:int = 0
var _desired_nb_of_keys:int = 0
var _closed_doors:Dictionary		# <id, position>
var _keys_of_doors_to_drop:Array	# <id>
var _dropped_keys:Dictionary		# <id, position>

var use_gridmap:bool
var tile_size:int
var spawn_position:Vector3

##################### DEBUG AREA #####################
const DEBUG:bool = false
const FORCE_START_DOOR:bool = false
const FORCE_END_DOOR:bool = false
const DISABLE_COLLISION:bool = false
const SHOW_DOOR_INSERTIONS:bool = false
const SHOW_STARTING_ROOM:bool = false
const SHOW_ENDING_ROOM:bool = false
const DRAW_ROOMS_INDEX:bool = false
const PRINT_REFUSED_DUNGEON:bool = true
const PRINT_LADDER:bool = false
const PRINT_ROOMS_TRAVEL:bool = true
const PRINT_DOOR_LOCATION:bool = false
const PRINT_DOOR_KEYS:bool = true
const TEST_DOOR_KEYS_EQUALITY:bool = true
const DESIRED_SEED_STEP_COUNTER:int = 50
var _desired_seed_counter:int = 0
var _seed_counter:int = 1

var testCase := Dictionary()
var nbOfCase:int = 0
var _continue_looping = false
var _timer_value:float = 1
var _timer_looping:Timer
##################### DEBUG AREA #####################

func _ready():
	var tiles:Array = get_tree().get_nodes_in_group("Tiles")
	for tile in tiles:
		tile.connect("on_translate", self, "_on_tile_translate")
	
	if DEBUG: 
		for i in range(nbOfCase):
			testCase[i] = false
		
		if _continue_looping:
			_timer_looping = Timer.new()
			_timer_looping.connect("timeout", self, "_on_timer_looping_timeout")
			_timer_looping.one_shot = true
			add_child(_timer_looping)


func _on_timer_looping_timeout():
	if _continue_looping:
		_desired_seed_counter += DESIRED_SEED_STEP_COUNTER
		_timer_looping.start(_timer_value)
		emit_signal("request_new_dungeon")

func _input(event):
	if DEBUG && event is InputEventKey and not event.is_pressed():
		if event.scancode == KEY_KP_ADD:
			_desired_seed_counter += DESIRED_SEED_STEP_COUNTER
			if not _continue_looping:
				_continue_looping = true
			emit_signal("request_new_dungeon")

func _on_tile_translate(source:MultiMeshInstance, pos:Vector3, angle_z:float):
	if not (DEBUG && DISABLE_COLLISION):
		var type:String = source.name.left(source.name.length() -1)
		var static_body = _resourceMgr.STATIC_BODIES.get(_eTilesType[type])
		if static_body:
			var body:Spatial = static_body.instance()
			body.translate(pos)
			body.rotate_z(angle_z)
			body.add_to_group("MapElements")
			add_child(body)


func gen_dungeon(graph_generator:GraphGenerator) -> bool:
	clear_all()
	_graph_generator = graph_generator
	_pathfinding = _graph_generator.pathfinding
	_rooms_areas = _graph_generator.rooms_areas
	_desired_nb_of_keys = _get_number_of_keys(_graph_generator.shortest_path.size())
	if PRINT_DOOR_KEYS: print("nbKeys = ", _desired_nb_of_keys)
	var startMiddle:Vector3 = _geometry.to_vector3(_graph_generator.starting_room.get_middle())
	_fill_the_map()
	_write_rooms_on_map()
	if _write_corridors_on_map():
		return false #emit_signal("request_new_dungeon")
	else:
		var door = _add_outside_door(_graph_generator.starting_room)
		if door:
			spawn_position = door.translation
		#else:
		#	emit_signal("request_new_dungeon")
		_add_outside_door(_graph_generator.ending_room)
		if DEBUG:
			var endMiddle:Vector3 = _geometry.to_vector3(_graph_generator.ending_room.get_middle())
			_apply_tile_on_tilemap(startMiddle, _eTilesType.Start)
			_apply_tile_on_tilemap(endMiddle, _eTilesType.End)
		
		if not use_gridmap:
			var tiles = get_tree().get_nodes_in_group("Tiles")
			for tile in tiles:
				tile.translate_all()
				pass
		
		_seed_counter += 1
		if DEBUG:
			if TEST_DOOR_KEYS_EQUALITY:
				if _dropped_keys.size() != _closed_doors.size():
					_continue_looping = false
					print("================================ Desired = ",_desired_nb_of_keys, " dropped keys = ", _dropped_keys.size())
					
				if _closed_doors.size() != _desired_nb_of_keys:
					print("================================ Desired = ",_desired_nb_of_keys, " closed doors = ", _closed_doors.size())
			if _continue_looping:
				if _seed_counter < _desired_seed_counter:
					return false #emit_signal("request_new_dungeon")
				else:
					_timer_looping.start(_timer_value)
			else:
				print("seed_counter = ", _seed_counter)
		
		emit_signal("dungeon_gen_finished", _graph_generator)
		return true


func _fill_the_map():
	for x in range(_graph_generator.map_width):
		for y in range(_graph_generator.map_height):
			var v = Vector3(x, y, 0)
			_apply_tile_on_tilemap(v, _eTilesType.Wall)


func _get_rooms_resource(resource:Dictionary, size:Vector2) -> Array:
	var w:Dictionary = resource.get(int(size.x))
	if w:
		return w.get(int(size.y))
	return []	
				

func _write_rooms_on_map():
	for room in _rooms_areas.values():
		var room_rect:Rect2 = room.get_room_rect()
		var room_position:Vector3 = _geometry.to_vector3(_geometry.vector2_floor(room.get_middle()))
		var prefab_resource:Array = _get_rooms_resource(_resourceMgr.ROOM_PREFAB, room_rect.size)
		var prefab = _place_object(room_position, prefab_resource)
		if prefab:
			room.prefab = prefab
		var background_resource:Array = _get_rooms_resource(_resourceMgr.ROOM_BACKGROUND, room_rect.size)
		var background:Spatial = _place_object(room_position, background_resource)
		if background:
			room.background = background
		
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
	var shortest_path = _graph_generator.shortest_path
	
	for point in _graph_generator.rooms_areas.keys():
		for connection in _pathfinding.get_point_connections(point):
			if not connection in rooms_done:
				if PRINT_ROOMS_TRAVEL: print(str(point) + " -> " + str(connection))
				var posRoom1:Vector3 = _pathfinding.get_point_position(point)
				var posRoom2:Vector3 = _pathfinding.get_point_position(connection)
				var start = _rooms_areas[point].gen_door_location(_geometry.to_vector2(posRoom2))
				var end = _rooms_areas[connection].gen_door_location(_geometry.to_vector2(posRoom1))
				var s:bool = false
				var e:bool = false
				var pointDeadEnd:bool = false
				var connectionDeadEnd:bool = false
				if point in shortest_path && connection in shortest_path:
					var closeEndingRoom:bool = _rooms_areas[point] == _graph_generator.ending_room && _desired_nb_of_keys > 0
					if rnd.randi() % 2 == 0:
						e = _should_lock() || closeEndingRoom
					else:
						s = _should_lock()
				elif _pathfinding.get_point_connections(point).size() == 1:
					pointDeadEnd = true
					#print("dead end point = ", point)
				elif _pathfinding.get_point_connections(connection).size() == 1:
					connectionDeadEnd = true
					#print("dead end connection = ", connection)
				
				if s || e:
					print("Close door = ", point, " -> ", connection)
				
				var dropKey:bool = _should_drop_key(pointDeadEnd || connectionDeadEnd)
				if dropKey:
					var key_position:Vector3
					var prefab
					if pointDeadEnd:
						prefab = _rooms_areas[point].prefab
					else:
						prefab = _rooms_areas[connection].prefab
					
					print("drop key / prefab = ", prefab)
					if prefab:
						key_position = prefab.get_key_spot(rnd)
						print("key position = ", key_position)
						_drop_key(key_position)
					else:
						print("No prefab found")
				
				var error:bool = _dig_path(start, end, s || FORCE_START_DOOR, e || FORCE_END_DOOR)
				if error:
					return error
		rooms_done.append(point)
	return false

func _add_outside_door(room:Room):
	var room_rect:Rect2 = room.get_room_rect()
	var bottom:Vector2 = room_rect.position
	var middle:Vector2 = room.get_middle()
	var vectorTileSize = Vector2(tile_size * 3, tile_size * 3)
	for x in range (room_rect.size.x / 2):
		for i in range(-1, 2, 2):
			var v:Vector2 = Vector2(middle.x + i * x, bottom.y)
			var v_rect:Rect2 = Rect2(v - vectorTileSize, vectorTileSize * 2)
			for out in room.output_locations:
########################################## A VIRER après debug.
				var debug = avirer.instance()
				debug.translate(_geometry.to_vector3(out) * tile_size)
				debug.add_to_group("MapElements")
				add_child(debug)
##########################################
				var out_rect:Rect2 = Rect2(out - vectorTileSize, vectorTileSize * 2)
				if not v_rect.intersects(out_rect):
					var door = _place_object(_geometry.to_vector3(v), _resourceMgr.IN_OUT_DOOR)
					if get_parent().context and get_parent().context.has("spawn_position"):
						door.spawn_position = get_parent().context.spawn_position
					return door
	return null

func _dig_path(start: Dictionary, end: Dictionary, lockDoorOnStart: bool = false, lockDoorOnEnd: bool = false) -> bool:	# Return true on error
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
			_dig_horizontally(startPos, endPos, putMobSpawn, lockDoorOnStart, lockDoorOnEnd)
		elif verticalPath:		# Vertical direction only
			_dig_vertically(startPos, endPos, putMobSpawn, lockDoorOnStart, lockDoorOnEnd)
		else:					# Mixed directions
			if horizontalStart && verticalEnd:
				_dig_mixed_directions(startPos, endPos, putMobSpawn, lockDoorOnStart, lockDoorOnEnd)
			elif verticalStart && horizontalEnd:
				_dig_mixed_directions(endPos, startPos, putMobSpawn, lockDoorOnEnd, lockDoorOnStart)
		
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


func _dig_horizontally(startPos: Vector3, endPos: Vector3, mobSpawn: bool, lockDoorOnStart: bool, lockDoorOnEnd: bool):
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
		if x == startPos.x + step.x:
			if step.x > 0:
				_apply_tile_on_tilemap(v, _eTilesType.Door, PI * 0.5, { "lock":lockDoorOnStart })
			else:
				_apply_tile_on_tilemap(v, _eTilesType.Door, PI * 1.5, { "lock":lockDoorOnStart })
		if x == endPos.x - step.x:
			if step.x > 0:
				_apply_tile_on_tilemap(v, _eTilesType.Door, PI * 1.5, { "lock":lockDoorOnEnd })
			else:
				_apply_tile_on_tilemap(v, _eTilesType.Door, PI * 0.5, { "lock":lockDoorOnEnd })
		else:
			if x != middlePos.x || step.y == 0:
				_apply_tile_on_tilemap(v, _eTilesType.PipeStraight, PI * 0.5)
	
	var toggleRight:bool = _first_step_is_on_right(dif, step)
	for y in range(startPos.y, endPos.y + step.y, step.y):
		var v = Vector3(middlePos.x, y, 0)
		var isEndOfLadder:bool = false
		if step.y > 0:
			isEndOfLadder = y == int(endPos.y)
			if step.x > 0:
				if y == startPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI)
				elif y == endPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.PipeStraight)
			else:
				if y == startPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 1.5)
				elif y == endPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 0.5)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.PipeStraight)
		else:
			isEndOfLadder = y == int(startPos.y)
			if step.x > 0:
				if y == startPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 0.5)
				elif y == endPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 1.5)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.PipeStraight)
				pass
			else:
				if y == startPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn)
				elif y == endPos.y:
					_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.PipeStraight)
				pass
		if not isEndOfLadder:
			if toggleRight:
				_apply_tile_on_tilemap(v, _eTilesType.Ladder)
			else:
				_apply_tile_on_tilemap(v, _eTilesType.Ladder, PI)
			toggleRight = not toggleRight


func _dig_vertically(startPos: Vector3, endPos: Vector3, mobSpawn: bool, lockDoorOnStart: bool, lockDoorOnEnd: bool):
	startPos = _geometry.vector3_floor(startPos)
	endPos = _geometry.vector3_floor(endPos)
	var dif = _geometry.vector3_floor(endPos - startPos)
	var middlePos = _geometry.vector3_round(startPos + (dif / 2))
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	var top:Vector3 = endPos
	var bottom:Vector3 = startPos
	var lockDoorOnTop = lockDoorOnEnd
	var lockDoorOnBottom = lockDoorOnStart
	
	if step.y < 0:
		top = startPos
		bottom = endPos
		lockDoorOnTop = lockDoorOnStart
		lockDoorOnBottom = lockDoorOnEnd
		step = - step
	
	if mobSpawn:
		_add_mob_spawn(middlePos)
	
	for x in range(bottom.x, top.x + step.x, step.x):
		var v = Vector3(x, middlePos.y, 0)
		if step.x > 0:
			if x == bottom.x:
				_apply_tile_on_tilemap(v, _eTilesType.PipeTurn)
			elif x == top.x:
				_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI)
			else:
				_apply_tile_on_tilemap(v, _eTilesType.PipeStraight, PI * 0.5)
		else:
			if x == bottom.x:
				_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 0.5)
			elif x == top.x:
				_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 1.5)
			else:
				_apply_tile_on_tilemap(v, _eTilesType.PipeStraight, PI * 0.5)
	
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
				
		if y == bottom.y + step.y:
			_apply_tile_on_tilemap(v, _eTilesType.Door, 0, { "lock":lockDoorOnBottom })
			toggleRight = not toggleRight
			
		if y == top.y - step.y:
			_apply_tile_on_tilemap(v, _eTilesType.Door, PI, { "lock":lockDoorOnTop })
			toggleRight = not toggleRight
		else:
			if y != middlePos.y || step.x == 0:
				_apply_tile_on_tilemap(v, _eTilesType.PipeStraight)
			var isEndOfLadder:bool = false
			if step.y > 0:
				isEndOfLadder = y == int(top.y) || y == int(top.y - step.y)
				
			elif step.y == 0:
				isEndOfLadder = true
			
			if not isEndOfLadder:
				if toggleRight:
					_apply_tile_on_tilemap(v, _eTilesType.Ladder)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.Ladder, PI)
				toggleRight = not toggleRight
			#else:
				#_apply_tile_on_tilemap(v, _eTilesType.Empty)


func _dig_mixed_directions(horizontalPos: Vector3, verticalPos: Vector3, mobSpawn: bool, lockDoorOnHorizontal: bool, lockDoorOnVertical: bool):
	
################# debug #################
	#_continue_looping = false
################# debug #################
	
	horizontalPos = _geometry.vector3_floor(horizontalPos)
	verticalPos = _geometry.vector3_floor(verticalPos)
	var dif = _geometry.vector3_floor(verticalPos - horizontalPos)
	var step = Vector2(sign(dif.x), sign(dif.y))
	
	if mobSpawn:
		_add_mob_spawn(Vector3(verticalPos.x, horizontalPos.y, 0))
	
	for x in range(horizontalPos.x + step.x, verticalPos.x, step.x):
		var v = Vector3(x, horizontalPos.y, 0)
		if x == horizontalPos.x + step.x:
			if step.x > 0:
				_apply_tile_on_tilemap(v, _eTilesType.Door, PI * 0.5, {"lock":lockDoorOnHorizontal })
			else:
				_apply_tile_on_tilemap(v, _eTilesType.Door, PI * 1.5, {"lock":lockDoorOnHorizontal })
		else:
			_apply_tile_on_tilemap(v, _eTilesType.PipeStraight, PI * 0.5)
	
	var toggleRight:bool = _first_step_is_on_right(dif, step)
	for y in range(horizontalPos.y, verticalPos.y, step.y):
		var v = Vector3(verticalPos.x, y, 0)
		if y == verticalPos.y - step.y:
			if step.y > 0:
				_apply_tile_on_tilemap(v, _eTilesType.Door, PI, {"lock":lockDoorOnVertical })
			else:
				_apply_tile_on_tilemap(v, _eTilesType.Door, 0, {"lock":lockDoorOnVertical })
		else:
			if y != horizontalPos.y:
				_apply_tile_on_tilemap(v, _eTilesType.PipeStraight)
			
			var isEndOfLadder:bool = false
			if step.y > 0:
				isEndOfLadder = y == int(verticalPos.y)
				if y == horizontalPos.y:
					if step.x > 0:
						_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI)
					else:
						_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 1.5)
			else:
				isEndOfLadder = y == int(horizontalPos.y)
				if y == horizontalPos.y:
					if step.x > 0:
						_apply_tile_on_tilemap(v, _eTilesType.PipeTurn, PI * 0.5)
					else:
						_apply_tile_on_tilemap(v, _eTilesType.PipeTurn)
				
			if not isEndOfLadder:
				if toggleRight:
					_apply_tile_on_tilemap(v, _eTilesType.Ladder)
				else:
					_apply_tile_on_tilemap(v, _eTilesType.Ladder, PI)
				toggleRight = not toggleRight

func _get_number_of_keys(nb_rooms_on_path:int) ->int:
	var valrange = int(floor(key_occupation * (nb_rooms_on_path - 1) - min_nb_key))
	if valrange > 0:
		print("key range = ", valrange)
		return min_nb_key + (rnd.randi() % valrange)
	return 0

func _should_lock() ->bool:
	_pathRoomsCounter += 1
	var remainingRoomsToClose:int = _desired_nb_of_keys - _closed_doors.size()
	var remainingDoorsOnPath:int = _graph_generator.shortest_path.size() - 2 - _pathRoomsCounter - remainingRoomsToClose
	if remainingDoorsOnPath > 0 && _closed_doors.size() < _desired_nb_of_keys:
		var hazard = rnd.randf()
		print("Should lock : ",hazard, " <= ", remainingRoomsToClose, " / ", remainingDoorsOnPath)
		if hazard <= (float(remainingRoomsToClose) / float(remainingDoorsOnPath)):
			return true
	return false


func _should_drop_key(is_dead_end:bool) ->bool:
	_totalRoomsCounter += 1
	if _keys_of_doors_to_drop.size() > 0:
		var remainingRooms:int = _rooms_areas.size() - 1 - _totalRoomsCounter
		if remainingRooms <= 0:
			remainingRooms = 1
		var hazard = rnd.randf()
		print("_should_drop_key :", is_dead_end, " || ", hazard, " <= ", _keys_of_doors_to_drop.size(), " / ", remainingRooms)
		if is_dead_end || hazard <= (float(_keys_of_doors_to_drop.size()) / float(remainingRooms)):
			return true
	return false


func _drop_key(pos:Vector3):
	if _keys_of_doors_to_drop.size() > 0:
		var id = _keys_of_doors_to_drop.front()
		_dropped_keys[id] = pos
		var key = _place_object(pos, _resourceMgr.KEYS_RESOURCES, Vector3.ZERO, 0, false)
		if key == null:
			print("No key find in the resources : ", _resourceMgr.KEYS_RESOURCES)
		else:
			key.id_door = id
			_keys_of_doors_to_drop.erase(id)

func _add_mob_spawn(pos:Vector3):
	if _place_object(pos, _resourceMgr.MOB_RESOURCES) == null:
		print("No mob find in the resources : ", _resourceMgr.MOB_RESOURCES)


func _place_object(pos:Vector3, resources:Array, dir:Vector3 = Vector3.ZERO, angle:float = 0, scale_by_tilesize = true) -> Spatial:
	if resources.size() > 0:
		var variant = rnd.randi() % resources.size()
		var resource = resources[variant]
		if resource:
			var object = resource.instance()
			if scale_by_tilesize:
				object.translate(pos * tile_size)
			else:
				object.translate(pos)
			if angle != 0:
				object.rotate(dir, angle)
			object.add_to_group("MapElements")
			add_child(object)
			return object
	return null


func _apply_tile_on_tilemap(pos: Vector3, tileType: int, angle_z:float = 0, parameter = null):
	if use_gridmap:
		$GridMap.set_cell_item(pos.x, pos.y, pos.z, tileType)
	else:
		var v:Vector3 = pos * tile_size
		
		$Wall0.delete_tile_at(v)
		match tileType:
			_eTilesType.Wall:
				match rnd.randi() % 1:
					0:
						$Wall0.insert(v, angle_z)
			
			_eTilesType.Door:
				var door = _place_object(pos, _resourceMgr.INTERIOR_DOORS, Vector3.FORWARD, angle_z)
				if door == null:
					print("No door found in the resources : ", _resourceMgr.INTERIOR_DOORS)
				else:
					if parameter != null:
						door.set_locked(parameter.lock)
						if parameter.lock:
							door.id = _currentDoorID
							_closed_doors[_currentDoorID] = v
							_keys_of_doors_to_drop.append(_currentDoorID)
							_currentDoorID += 1
			
			_eTilesType.Ladder:
				match rnd.randi() % 2:
					0:
						$Ladder0.insert(v, angle_z)
					1:
						$Ladder1.insert(v, angle_z)
			
			_eTilesType.PipeStraight:
				match rnd.randi() % 2:
					0:
						$PipeStraight0.insert(v, angle_z)
					1:
						$PipeStraight1.insert(v, angle_z)
			
			_eTilesType.PipeTurn:
				match rnd.randi() % 2:
					0:
						$PipeTurn0.insert(v, angle_z)
					1:
						$PipeTurn1.insert(v, angle_z)
			
			_eTilesType.DoorInsertion:
				if DEBUG && SHOW_DOOR_INSERTIONS:
					$DoorInsertion0.insert(v, angle_z)
			
			_eTilesType.Start:
				if DEBUG && SHOW_STARTING_ROOM:
					$Start0.insert(v, angle_z)
			
			_eTilesType.End:
				if DEBUG && SHOW_ENDING_ROOM:
					$End0.insert(v, angle_z)


func clear_all():
	print("===============================================")
	_closed_doors.clear()
	_keys_of_doors_to_drop.clear()
	_dropped_keys.clear()
	_currentDoorID = 0
	_pathRoomsCounter = 0
	_totalRoomsCounter = 0
	_desired_nb_of_keys = 0
	
	var mapElements = get_tree().get_nodes_in_group("MapElements")
	for element in mapElements:
		element.queue_free()
	
	var tiles = get_tree().get_nodes_in_group("Tiles")
	for tile in tiles:
		tile.clear()