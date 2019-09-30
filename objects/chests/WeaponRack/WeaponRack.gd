extends Spatial


var id := 0

var _items := []


# Called when the node enters the scene tree for the first time.
func _ready():
	if _items.empty():
		_hide_weapons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func add_item(item: Item):
	
	if item.type == "gun" and not item.properties.has("type"):
		item.properties["type"] = "pistol"
	
	_items.append(item)
	_show_weapons()


func remove_item(item: Item):
	var index = _items.find(item)
	if index != -1:
		_items.remove(index)
	if _items.empty():
		_hide_weapons()


func give_all(actor):
	if not actor.has_method("give_item"):
		return
	print("Give all items (%d)" % [_items.size()] )
	for item in _items:
		actor.give_item(item)
	_items.clear()
	_hide_weapons()


func _show_weapons():
	for weapon in $WeaponRack.get_children():
		weapon.visible = true


func _hide_weapons():
	for weapon in $WeaponRack.get_children():
		weapon.visible = false
