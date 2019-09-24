extends Node

signal item_added(item)
signal item_removed(item)

export var auto_equip := true


var items := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func equip(item):
	if item.type == "gun":
		$"../WeaponHandler".equip_weapon(item)
	pass


func get_items() -> Array:
	var all_items := []
	#for item in weapons:
	#	all_items.append(item)
	#for item in ammos:
	#	all_items.append(item)
	for item in items:
		all_items.append(item)
	return all_items


func add_item(item: Item):
	item["equiped"] = false
	items.append(item)
	if item.type == "gun":
		#weapons.append(item)
		emit_signal("item_added", item)
		if auto_equip and $"../WeaponHandler".weapon == null:
			$"../WeaponHandler".equip_weapon(item)
	elif item.type == "ammo":
		#ammos.append(item)
		emit_signal("item_added", item)
		$"../AmmoHandler".add_ammo(item)
		if auto_equip and $"../AmmoHandler".ammo_available_list.size() == 1:
			$"../AmmoHandler".select_next()
	
	


func remove_item(item: Item) -> bool:
	var index := items.find(item)
	if index != -1:
		items.remove(index)
		emit_signal("item_removed", item)
	return false


func save():
	print("save weapons: ", items )
	print("save weapons json: ", to_json(items) )
	
	var data = {
		"items": [],
	}
	for item in items:
		data.weapons.append( item.save() )
	return data


func restore( data ):
	items = []
	for item_data in data.items:
		var item = Item.new()
		item.restore(item_data)
		add_item( item )