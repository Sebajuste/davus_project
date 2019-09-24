extends Spatial

export var id : int = 0 setget _set_id
export var locked := false setget set_locked
export var auto_open := false
export var auto_closed := true
export var auto_closed_time := 5.0
export var use_delete_key := false

var opened := false


func _ready():
	$CloseTimer.wait_time = auto_closed_time
	set_locked(locked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func use(actor) -> bool:
	return _unlock(actor)


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


func _unlock(actor):
	if locked and actor.is_in_group("player"):
		var items = actor.get_items()
		for item in items:
			if item.type == "key" and item.properties["id_door"] == id:
				set_locked( false )
				if use_delete_key:
					actor.remove_item(item)
	if not locked:
		return open()
	return false


func _on_CloserTimer_timeout():
	
	close()
	


func _on_Area_body_entered(body):
	if auto_open and body.is_in_group("player"):
		_unlock(body)


func _on_Area_body_exited(body):
	if auto_open and body.is_in_group("player"):
		close()
