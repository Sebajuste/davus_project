extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var _usable_list := []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_usable() -> Spatial:
	var nearest_usable = null
	var nearest_distance : int
	for usable in _usable_list:
		var distance = (usable.global_transform.origin - self.global_transform.origin).length()
		if nearest_usable == null or distance < nearest_distance:
			nearest_distance = distance
			nearest_usable = usable
	return nearest_usable


func _on_UsableArea_area_entered(area):
	_usable_list.append(area)
	pass # Replace with function body.


func _on_UsableArea_area_exited(area):
	var index = _usable_list.find(area)
	if index != -1:
		_usable_list.remove(index)
