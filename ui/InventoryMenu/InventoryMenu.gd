extends Control

signal item_equiped(item)

const WeaponPanel = preload("WeaponPanel/WeaponPanel.tscn")
const AmmoPanel = preload("AmmoPanel/AmmoPanel.tscn")

enum EquipmentType { WEAPON_MAIN, WEAPON_SECONDARY, AMMO, JETPACK }


export(NodePath) var inventory = null

onready var inventory_node: Node


var active := true setget set_active

#var weapons := []

#var ammos := []

var _current_equipment_type

onready var _equipment_type_list := [
	$MarginContainer/HBoxContainer/Tabs/WeaponMain,
	$MarginContainer/HBoxContainer/Tabs/Ammo,
	#$MarginContainer/HBoxContainer/Tabs/Jetpack,
]

onready var _current_list = _equipment_type_list

var _select_pos = 0

var equipment := {
	"weapon_main": null,
	"weapon_secondary": null,
	"ammo": null,
	"jetpack": null
}


onready var _list = $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if inventory:
		inventory_node = get_node(inventory)
	
	_current_equipment_type = EquipmentType.WEAPON_MAIN
	select_weapons()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if not active:
		return
	
	if Input.is_action_just_pressed("ui_up"):
		_select_pos -= 1
		if _select_pos < 0:
			_select_pos = _current_list.size() - 1
		_current_list[_select_pos].grab_focus()
		#print("_select_pos: ", _select_pos, ", _current_list.size(): ", _current_list.size(), ", name: ", _current_list[_select_pos].name )
	
	if Input.is_action_just_pressed("ui_down"):
		_select_pos += 1
		if _select_pos >= _current_list.size():
			_select_pos = 0
		_current_list[_select_pos].grab_focus()
		#print("_select_pos: ", _select_pos, ", _current_list.size(): ", _current_list.size(), ", name: ", _current_list[_select_pos].name)
	
	if Input.is_action_just_pressed("ui_accept"):
		_current_list[_select_pos].emit_signal("pressed")
		#print("_select_pos: ", _select_pos, ", _current_list.size(): ", _current_list.size(), ", name: ", _current_list[_select_pos].name)
	


func set_active(value):
	active = value
	if active:
		_select_pos = 0
		select_weapons()
		_current_list[_select_pos].grab_focus()


func deselect() -> void:
	for child in _list.get_children():
		_list.remove_child(child)


func select_weapons() -> void:
	deselect()
	for weapon in _get_weapons():
		var weapon_panel = WeaponPanel.instance()
		weapon_panel.weapon = weapon
		weapon_panel.connect("item_selected", self, "_item_selected")
		_list.add_child(weapon_panel)


func select_ammos() -> void:
	deselect()
	for ammo in _get_ammos():
		var panel = AmmoPanel.instance()
		panel.ammo = ammo
		panel.connect("item_selected", self, "_item_selected")
		_list.add_child(panel)
		

func _get_weapons() -> Array:
	var weapons := []
	print("inventory_node: ", inventory_node)
	if inventory_node != null:
		for item in inventory_node.items:
			if item.type == "gun":
				if item.equiped:
					equipment["weapon_main"] = item
				weapons.append(item)
	return weapons


func _get_ammos() -> Array:
	var ammos := []
	if inventory_node != null:
		for item in inventory_node.items:
			if item.type == "ammo":
				if item.equiped:
					equipment["ammo"] = item
				ammos.append(item)
	return ammos


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
	
	inventory_node.equip(item)


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
