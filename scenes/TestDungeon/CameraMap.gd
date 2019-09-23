extends Camera

export var speed = 50

func _ready():
	pass # Replace with function body.

func _process(delta):
	if current:
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
			
		translate( cam_move * delta )