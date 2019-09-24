extends Control

signal item_equiped(item)

const WeaponPanel = preload("WeaponPanel/WeaponPanel.tscn")
const AmmoPanel = preload("AmmoPanel/AmmoPanel.tscn")

enum EquipmentType { WEAPON_MAIN, WEAPON_SECONDARY, AMMO, JETPACK }

var weapons := []

var ammos := []

var _current_equipment_type

var equipment := {
	"weapon_main": null,
	"weapon_secondary": null,
	"ammo": null,
	"jetpack": null
}


onready var _list = $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	_current_equipment_type = EquipmentType.WEAPON_MAIN
	select_weapons()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func add_item(item: Item) -> bool:
	print("add item: ", item.save() )
	match item.type:
		"gun":
			weapons.append(item)
			return true
		"ammo":
			ammos.append(item)
			return true
		_:
			return false


func remove_item(item: Item) -> void:
	var index = weapons.find(item)
	if index != -1:
		weapons.remove(index)


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


func select_ammos() -> void:
	deselect()
	for ammo in ammos:
		var panel = AmmoPanel.instance()
		panel.ammo = ammo
		panel.connect("item_selected", self, "_item_selected")
		_list.add_child(panel)
		


func _item_selected(item: Item):
	if item.equiped:
		return
	
	match _current_equipment_type:
		EquipmentType.WEAPON_MAIN:
			if equipment["weapon_main"]:
				equipment["weapon_main"].equiped = false
			item.equiped = true
			equipment["weapon_main"] = item
			select_weapons()
		EquipmentType.WEAPON_SECONDARY:
			if equipment["weapon_secondary"]:
				equipment["weapon_secondary"].equiped = false
			item.equiped = true
			equipment["weapon_secondary"] = item
			select_weapons()
		EquipmentType.AMMO:
			if equipment["ammo"]:
				equipment["ammo"].equiped = false
			item.equiped = true
			equipment["ammo"] = item
			select_ammos()

		EquipmentType.JETPACK:
			if equipment["jetpack"]:
				equipment["jetpack"].equiped = false
			item.equiped = true
			equipment["jetpack"] = item
		_:
			return
	
	emit_signal("item_equiped", item)
	
	pass



func _on_WeaponMain_pressed():
	_current_equipment_type = EquipmentType.WEAPON_MAIN
	select_weapons()


func _on_WeaponSecondary_pressed():
	_current_equipment_type = EquipmentType.WEAPON_SECONDARY
	select_weapons()


func _on_Ammo_pressed():
	_current_equipment_type = EquipmentType.AMMO
	select_ammos()


func _on_Jetpack_pressed():
	_current_equipment_type = EquipmentType.JETPACK
	deselect()
