extends Spatial

export var speed = 50

func _on_DungeonGenerator_graph_gen_finnished():
	var dg = $DungeonGenerator
	dg.generate_grid_map($GridMap)
	$Camera.translation.x = dg.map_width
	$Camera.translation.y = dg.map_height
	
func _process(delta):
	
	var cam_move = Vector3()
	
	if Input.is_action_pressed("ui_right"):
		cam_move += Vector3.RIGHT * speed
	
	if Input.is_action_pressed("ui_left"):
		cam_move += Vector3.LEFT * speed
	
	if Input.is_action_pressed("ui_up"):
		cam_move += Vector3.UP * speed
	
	if Input.is_action_pressed("ui_down"):
		cam_move += -Vector3.UP * speed
	
	if Input.is_action_pressed("zoom_forward") or Input.is_key_pressed(KEY_Z):
		cam_move += Vector3.FORWARD * speed
	
	if Input.is_action_pressed("zoom_backward") or Input.is_key_pressed(KEY_S):
		cam_move += Vector3.BACK * speed
	
	$Camera.translate( cam_move * delta )