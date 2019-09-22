extends Spatial

# Minimap Parameters
export var scale2D:int = 2

# Dungeon Generator Parameters
export var room_margin:int = 2
export (int, 2, 10) var number_of_rooms:int = 12
export var number_of_keys:int = 1
export var map_width:int = 80
export var map_height:int = 50
export var min_room_width:int = 9
export var max_room_width:int = 9
export var min_room_height:int = 5
export var max_room_height:int = 5
export (float, 0, 1) var mob_chance_corridors:float = 0.5
export var map_seed = 1
const TILE_SIZE = 2
const USE_GRIDMAP = false
const DRAW_ROOMS_INDEX = true

var _control_camera:bool = false
var _rnd := RandomNumberGenerator.new()
var _graph_generator := GraphGenerator.new()

func _ready():
	_select_camera()
	_rnd.seed = map_seed
	
	_graph_generator.connect("graph_gen_finished", self, "_graph_gen_finished")
	
	# Initiate graph generator
	_graph_generator.rnd = _rnd
	_graph_generator.room_margin = room_margin
	_graph_generator.number_of_rooms = number_of_rooms
	_graph_generator.number_of_keys = number_of_keys
	_graph_generator.map_width = map_width
	_graph_generator.map_height = map_height
	_graph_generator.min_room_width = min_room_width
	_graph_generator.max_room_width = max_room_width
	_graph_generator.min_room_height = min_room_height
	_graph_generator.max_room_height = max_room_height
	_graph_generator.map_seed = map_seed
	
	# Initiate map generator
	var dg := $MapGenerator
	dg.tile_size = TILE_SIZE
	dg.mob_chance_corridors = mob_chance_corridors
	dg.rnd = _rnd
	
	# Initiate Mini map
	$MiniMap.scale2D = scale2D
	$MiniMap.draw_room_index = DRAW_ROOMS_INDEX
	
	create_dungeon()

func _input(event):
	if event is InputEventKey and not event.is_pressed():
		if event.scancode == KEY_9:
			_select_camera()
		if event.scancode == KEY_8:
			create_dungeon()

func _select_camera():
	$CameraPlayer.current = not _control_camera
	$CameraMap.current = _control_camera
	_control_camera = not _control_camera

func create_dungeon():
	var mg := $MapGenerator
	_graph_generator.clear_all()
	mg.clear_all()
	_graph_generator.gen_graph()
	mg.gen_dungeon(_graph_generator)
	$MiniMap.graph_generator = _graph_generator
	$MiniMap.gen()

"""
func _on_DungeonGenerator_graph_gen_finnished():
	var mg := $MapGenerator
	$CameraMap.translation.x = mg.map_width
	$CameraMap.translation.y = mg.map_height
	$CameraMap.translation.z = mg.map_width
	var spawn:Vector3 = mg.spawn_position
	$Player.global_transform.origin = spawn
	$Player/CombatStats.heal( $Player/CombatStats.max_health )
"""

func _graph_gen_finished():
	$CameraMap.translation.x = _graph_generator.map_width
	$CameraMap.translation.y = _graph_generator.map_height
	$CameraMap.translation.z = _graph_generator.map_width

func _on_MapGenerator_dungeon_gen_finished():
	$Player.global_transform.origin = $MapGenerator.spawn_position
	$Player/CombatStats.heal( $Player/CombatStats.max_health )

func _on_MapGenerator_request_new_dungeon():
	create_dungeon()



