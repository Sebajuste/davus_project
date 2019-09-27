extends Spatial


var id := 0

var _items := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func add_item(item: Item):
	
	_items.append(item)
	


func remove_item(item: Item):
	var index = _items.find(item)
	if index != -1:
		_items.remove(index)


func give_all(actor):
	if not actor.has_method("give_item"):
		return
	for item in _items:
		actor.give_item(item)
		self.remove_item(item)
	_hide_weapons()


func _show_weapons():
	for weapon in $WeaponRack.get_children():
		weapon.visible = true


func _hide_weapons():
	for weapon in $WeaponRack.get_children():
		weapon.visible = false
