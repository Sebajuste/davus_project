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
			$MarginContainer/HBoxContainer/Icon.visible = true
			print( ammo.properties )
			match ammo.properties["ammo_type"]:
				"Normal":
					$MarginContainer/HBoxContainer/Icon.texture = preload("res://ui/Icons/Ammo/IconClipRegular64x64.png")
				"Fire":
					$MarginContainer/HBoxContainer/Icon.texture = preload("res://ui/Icons/Ammo/IconClipFire64x64.png")
				"Ice":
					pass
			
		_:
			$MarginContainer/HBoxContainer/Icon.visible = false
	
	$MarginContainer/HBoxContainer/Stats/Effect/Value.text = str(ammo.properties["ammo_type"])
	$MarginContainer/HBoxContainer/Equiped.visible = ammo.equiped



func _on_WeaponPanel_pressed():
	
	emit_signal("item_selected", ammo)
	
