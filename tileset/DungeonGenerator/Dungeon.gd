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

var _control_camera:bool = false

func _ready():
	_select_camera()
	var dg := $DungeonGenerator
	dg.room_margin = room_margin
	dg.number_of_rooms = number_of_rooms
	dg.number_of_keys = number_of_keys
	dg.map_width = map_width
	dg.map_height = map_height
	dg.min_room_width = min_room_width
	dg.max_room_width = max_room_width
	dg.min_room_height = min_room_height
	dg.max_room_height = max_room_height
	dg.mob_chance_corridors = mob_chance_corridors
	dg.map_seed = map_seed
	dg.gen_dungeon()

func _input(event):
	if event is InputEventKey and not event.is_pressed():
		if event.scancode == KEY_9:
			_select_camera()

func _select_camera():
	$CameraPlayer.current = not _control_camera
	$CameraMap.current = _control_camera
	_control_camera = not _control_camera


func _on_DungeonGenerator_graph_gen_finnished():
	var dg = $DungeonGenerator
	#dg.map = $GridMap
	$CameraMap.translation.x = dg.map_width
	$CameraMap.translation.y = dg.map_height
	$CameraMap.translation.z = dg.map_width
	var spawn:Vector3 = $DungeonGenerator.spawn_position
	$Player.global_transform.origin = spawn
	$Player/CombatStats.heal( $Player/CombatStats.max_health )

func _on_DungeonGenerator_dungeon_generated():
	pass
	#$Player.global_transform.origin = $DungeonGenerator.spawn_position
	#$Player/CombatStats.heal( $Player/CombatStats.max_health )