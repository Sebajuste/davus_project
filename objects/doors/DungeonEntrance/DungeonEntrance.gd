extends Spatial


export var locked := false setget set_locked

export var auto_closed := true
export var auto_closed_time := 5.0


var opened := false

var id : int = 0 setget set_id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CloseTimer.wait_time = auto_closed_time
	set_locked(locked)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_locked(value: bool) -> void:
	locked = value
	if locked:
		close()
		$Entrance/DoorPanel/OmniLight.light_color = Color.red
	else:
		$Entrance/DoorPanel/OmniLight.light_color = Color.green

func open() -> void:
	if not locked:
		opened = true
		if auto_closed:
			$CloseTimer.start()
	pass


func set_id(val: int) -> void:
	if id == 0:
		id = val


func close():
	opened = false
	pass


func use(actor):
	open()
	if opened:
		loading.change_scene("res://tileset/DungeonGenerator/Dungeon.tscn")
