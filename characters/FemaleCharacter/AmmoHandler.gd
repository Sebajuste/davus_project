extends Node

signal ammo_selected(ammo)

export var inventory: NodePath

export var auto_equip := true

onready var inventory_node := get_node(inventory)

var ammo_available_list := []
var current_ammo := -1

# Called when the node enters the scene tree for the first time.
func _ready():
	#ammo_available_list.append("normal")
	#current_ammo = 0
	
	#emit_signal("ammo_selected", "normal")
	
	inventory_node.connect("item_added", self, "_on_add_ammo")
	inventory_node.connect("item_removed", self, "_on_remove_ammo")
	inventory_node.connect("item_updated", self, "_on_update_ammo")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if Input.is_action_just_pressed("next_ammo"):
		select_next()
	
	pass


func get_ammo() -> Item:
	if not ammo_available_list.empty():
		return ammo_available_list[current_ammo]
	return null


func select_next():
	var index = current_ammo + 1
	if index >= ammo_available_list.size():
		index = 0
	ammo_available_list[current_ammo].equiped = false
	current_ammo = index
	var ammo = ammo_available_list[current_ammo]
	ammo.equiped = true
	emit_signal("ammo_selected", ammo)
	pass


func select_previous():
	pass


func _on_add_ammo(item: Item) -> void:
	if item.type == "ammo" and ammo_available_list.find(item) == -1:
		ammo_available_list.append(item)
		if auto_equip and ammo_available_list.size() == 1:
			select_next()


func _on_remove_ammo(item: Item) -> void:
	var index = ammo_available_list.find(item)
	if index != -1:
		ammo_available_list.remove(index)


func _on_update_ammo(item: Item) -> void:
	var index = ammo_available_list.find(item)
	if index != -1:
		current_ammo = index
		if item.equiped:
			emit_signal("ammo_selected", item)
