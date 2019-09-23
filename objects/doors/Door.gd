extends Spatial

export var locked := false setget set_locked

export var auto_open := false

export var auto_closed := true
export var auto_closed_time := 5.0

var opened := false

var id : int = 0 setget _set_id


func _ready():
	$CloseTimer.wait_time = auto_closed_time
	set_locked(locked)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use(actor) -> void:
	pass


func set_locked(value: bool) -> void:
	locked = value
	if locked:
		close()


func open() -> bool:
	if not locked and not opened:
		opened = true
		if auto_closed:
			$CloseTimer.start()
		return true
	return false


func close() -> bool:
	if opened:
		opened = false
		return true
	return false


func _set_id(val: int) -> void:
	if id == 0:
		id = val


func _on_CloserTimer_timeout():
	
	close()
	


func _on_Area_body_entered(body):
	if auto_open and body.is_in_group("player"):
		open()


func _on_Area_body_exited(body):
	if auto_open and body.is_in_group("player"):
		close()
