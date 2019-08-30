extends Spatial

const LevelBatch = preload("res://tools/LevelBatch.tscn")

export var speed = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)

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
	
	if Input.is_action_pressed("zoom_forward"):
		cam_move += Vector3.FORWARD * speed
	
	if Input.is_action_pressed("zoom_backward"):
		cam_move += Vector3.BACK * speed
	
	$Camera.translate( cam_move * delta )
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
