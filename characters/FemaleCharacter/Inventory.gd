extends Node

signal item_added(item)


export var auto_equip := true


var items := []

var weapons := []


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


func add_item(item):
	item["equiped"] = false
	if item.type == "gun":
		weapons.append(item)
		emit_signal("item_added", item)
		if auto_equip and $"../WeaponHandler".weapon == null:
			$"../WeaponHandler".equip_weapon(item)
	elif item.type == "ammo":
		items.append(item)
		$"../AmmoHandler".add_ammo(item)
		if auto_equip and $"../AmmoHandler".ammo_available_list.size() == 1:
			$"../AmmoHandler".select_next()
	else:
		items.append(item)

