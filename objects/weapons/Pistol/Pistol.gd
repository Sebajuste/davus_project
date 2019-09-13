extends Spatial

export(float, 60, 1200) var firing_rate := 60.0 setget _set_firing_rate

var _fire_ready := true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$FireTimer.wait_time = firing_rate / 60
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	
	pass


func shoot():
	
	if _fire_ready:
		print("shoot")
		_fire_ready = false
		$FireTimer.start()
	


func _set_firing_rate(fr):
	firing_rate = fr
	$FireTimer.wait_time = firing_rate / 60


func _on_FireTimer_timeout():
	_fire_ready = true
	pass # Replace with function body.
