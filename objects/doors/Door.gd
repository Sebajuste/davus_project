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


func open() -> void:
	if not locked:
		opened = true
		if auto_closed and $CloseTimer:
			$CloseTimer.start()


func close() -> void:
	opened = false


func _set_id(val: int) -> void:
	if id == 0:
		id = val
