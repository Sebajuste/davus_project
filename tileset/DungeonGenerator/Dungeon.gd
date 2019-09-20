extends Spatial

var _control_camera:bool = false

func _ready():
	_select_camera()

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


func _on_DungeonGenerator_dungeon_generated():
	$Player.global_transform.origin = $DungeonGenerator.spawn_position
	$Player/CombatStats.heal( $Player/CombatStats.max_health )