extends Button

signal item_selected(item)


var weapon: Item setget set_weapon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_weapon(item: Item) -> void:
	weapon = item
	match weapon.type:
		"gun":
			$MarginContainer/HBoxContainer/Gun.visible = true
		_:
			$MarginContainer/HBoxContainer/Gun.visible = false
	$MarginContainer/HBoxContainer/Stats/Damage/Value.text = str(weapon.properties["damage"])
	$MarginContainer/HBoxContainer/Stats/Rate/Value.text = str(weapon.properties["rate"])
	$MarginContainer/HBoxContainer/Equiped.visible = weapon.equiped



func _on_WeaponPanel_pressed():
	emit_signal("item_selected", weapon)
	pass # Replace with function body.
