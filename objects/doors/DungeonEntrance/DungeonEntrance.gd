extends Spatial


export var locked := false setget set_locked

export var auto_closed := true
export var auto_closed_time := 5.0


var open := false

# Called when the node enters the scene tree for the first time.
func _ready():
	$CloseTimer.wait_time = auto_closed_time
	set_locked(locked)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_locked(value):
	locked = value
	if locked:
		close()
		$Entrance/DoorPanel/OmniLight.light_color = Color.red
	else:
		$Entrance/DoorPanel/OmniLight.light_color = Color.green

func open():
	if not locked:
		if auto_closed:
			$CloseTimer.start()
	pass


func close():
	pass
