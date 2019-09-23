extends Node

signal ammo_selected(ammo)

export var inventory: NodePath


var ammo_available_list := []
var current_ammo := -1

# Called when the node enters the scene tree for the first time.
func _ready():
	#ammo_available_list.append("normal")
	#current_ammo = 0
	
	#emit_signal("ammo_selected", "normal")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if Input.is_action_just_pressed("next_ammo"):
		select_next()
	
	pass


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


func add_ammo(ammo: Item):
	
	if ammo_available_list.find(ammo) == -1:
		ammo_available_list.append(ammo)
	
	pass

