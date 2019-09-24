extends Node

signal item_added(item)


export var auto_equip := true


var items := []

var weapons := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_key_pressed( KEY_0 ):
		print("weapons: ", weapons)
	
	pass


func equip(item):
	if item.type == "gun":
		$"../WeaponHandler".equip_weapon(item)
	pass


func add_item(item: Item):
	item["equiped"] = false
	if item.type == "gun":
		weapons.append(item)
		emit_signal("item_added", item)
		if auto_equip and $"../WeaponHandler".weapon == null:
			$"../WeaponHandler".equip_weapon(item)
	elif item.type == "ammo":
		items.append(item)
		emit_signal("item_added", item)
		$"../AmmoHandler".add_ammo(item)
		if auto_equip and $"../AmmoHandler".ammo_available_list.size() == 1:
			$"../AmmoHandler".select_next()
	else:
		items.append(item)


func save():
	print("save weapons: ", weapons )
	print("save weapons json: ", to_json(weapons) )
	
	var data = {
		"weapons": [],
		"items": []
	}
	for weapon in weapons:
		data.weapons.append( weapon.save() )
	for item in items:
		data.items.append( item.save() )
	return data


func restore( data ):
	
	weapons = []
	for item_data in data.weapons:
		var item = Item.new()
		item.restore(item_data)
		add_item( item )
	
	items = []
	for item_data in data.items:
		var item = Item.new()
		item.restore(item_data)
		add_item( item )
	
	pass
