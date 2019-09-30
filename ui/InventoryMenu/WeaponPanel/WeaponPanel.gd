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
	if weapon.properties.has("type"):
		$MarginContainer/HBoxContainer/Pistol.visible = false
		$MarginContainer/HBoxContainer/SMG.visible = false
		$MarginContainer/HBoxContainer/Rifle.visible = false
		match weapon.properties["type"]:
			"pistol":
				$MarginContainer/HBoxContainer/Pistol.visible = true
			"smg":
				$MarginContainer/HBoxContainer/SMG.visible = true
			"rifle":
				$MarginContainer/HBoxContainer/Rifle.visible = true
	$MarginContainer/HBoxContainer/Stats/Damage/Value.text = str(weapon.properties["damage"])
	$MarginContainer/HBoxContainer/Stats/Rate/Value.text = str(weapon.properties["rate"])
	$MarginContainer/HBoxContainer/Equiped.visible = weapon.equiped
	
	var dps = (weapon.properties["damage"] * weapon.properties["rate"]) / 60
	$MarginContainer/HBoxContainer/Stats2/DPS/Value.text = str(dps)



func _on_WeaponPanel_pressed():
	emit_signal("item_selected", weapon)
	pass # Replace with function body.
