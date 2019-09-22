extends Spatial

export var locked := false setget set_locked

export var auto_closed := true
export var auto_closed_time := 5.0

var opened := false

var id : int = 0 setget _set_id


func _ready():
	if $CloseTimer:
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
		if auto_closed and $CloseTimer:
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
