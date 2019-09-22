extends Control

const WeaponPanel = preload("WeaponPanel/WeaponPanel.tscn")

enum EquipmentType { WEAPON_MAIN, WEAPON_SECONDARY, JETPACK }

var weapons := [{
	"type": "gun",
	"damage": 1.0,
	"rate": 1.0,
	"equiped": false
}, {
	"type": "gun",
	"damage": 0.5,
	"rate": 2.0,
	"equiped": false
}, {
	"type": "gun",
	"damage": 2.0,
	"rate": 0.5,
	"equiped": false
}]


var _current_equipment_type

var equipment := {
	"weapon_main": null,
	"weapon_secondary": null,
	"jetpack": null
}


onready var _list = $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(5):
		var weapon = {
			"type": "gun",
			"damage": rand_range(0.8, 1.2),
			"rate": rand_range(0.8, 1.2),
			"equiped": false
		}
		weapons.append(weapon)
	
	_current_equipment_type = EquipmentType.WEAPON_MAIN
	select_weapons()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func deselect() -> void:
	for child in _list.get_children():
		_list.remove_child(child)

func select_weapons() -> void:
	deselect()
	for weapon in weapons:
		var weapon_panel = WeaponPanel.instance()
		weapon_panel.weapon = weapon
		weapon_panel.connect("item_selected", self, "_item_selected")
		_list.add_child(weapon_panel)


func _item_selected(item):
	if item.equiped:
		return
	print("select: ", _current_equipment_type)
	item.equiped = true
	match _current_equipment_type:
		EquipmentType.WEAPON_MAIN:
			if equipment["weapon_main"]:
				equipment["weapon_main"].equiped = false
			equipment["weapon_main"] = item
			select_weapons()
		EquipmentType.WEAPON_SECONDARY:
			if equipment["weapon_secondary"]:
				equipment["weapon_secondary"].equiped = false
			equipment["weapon_secondary"] = item
			select_weapons()
		EquipmentType.JETPACK:
			if equipment["jetpack"]:
				equipment["jetpack"].equiped = false
			equipment["jetpack"] = item
		_:
			return
	
	pass



func _on_WeaponMain_pressed():
	print("select main")
	_current_equipment_type = EquipmentType.WEAPON_MAIN
	select_weapons()


func _on_WeaponSecondary_pressed():
	print("select secondary")
	_current_equipment_type = EquipmentType.WEAPON_SECONDARY
	select_weapons()
