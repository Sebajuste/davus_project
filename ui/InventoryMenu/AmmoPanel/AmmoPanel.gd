extends Button

signal item_selected(item)


var ammo: Item setget set_ammo

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_ammo(item: Item) -> void:
	ammo = item
	match ammo.type:
		"ammo":
			$MarginContainer/HBoxContainer/Ammo.visible = true
		_:
			$MarginContainer/HBoxContainer/Ammo.visible = false
	
	$MarginContainer/HBoxContainer/Stats/Effect/Value.text = str(ammo.properties["ammo_type"])
	$MarginContainer/HBoxContainer/Equiped.visible = ammo.equiped



func _on_WeaponPanel_pressed():
	
	emit_signal("item_selected", ammo)
	
