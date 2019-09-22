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
	
	var item = {
		"type": "ammo",
		"ammo_type": "normal"
	}
	ammo_available_list.append(item)
	select_next()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if Input.is_action_just_pressed("next_ammo"):
		select_next()
	
	pass


func select_next():
	current_ammo += 1
	if current_ammo >= ammo_available_list.size():
		current_ammo = 0
	emit_signal("ammo_selected", ammo_available_list[current_ammo])
	pass


func select_previous():
	pass


func add_ammo(ammo):
	
	if ammo_available_list.find(ammo) == -1:
		ammo_available_list.append(ammo)
	
	pass

