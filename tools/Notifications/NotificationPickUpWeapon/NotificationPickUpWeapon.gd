extends Panel


signal closed(notification)


export var damage : int = 0
export var rate : int = 0
export(String, "pistol", "smg", "rifle") var type = "pistol"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$VBoxContainer/HBoxContainer/Pistol.visible = false
	$VBoxContainer/HBoxContainer/SMG.visible = false
	$VBoxContainer/HBoxContainer/Rifle.visible = false
	match type:
		"pistol":
			$VBoxContainer/HBoxContainer/Pistol.visible = true
		"smg":
			$VBoxContainer/HBoxContainer/SMG.visible = true
		"rifle":
			$VBoxContainer/HBoxContainer/Rifle.visible = true
	
	$VBoxContainer/HBoxContainer/Control/MarginContainer/VBoxContainer/Damage/Value.text = str(damage)
	$VBoxContainer/HBoxContainer/Control/MarginContainer/VBoxContainer/FireRate/Value.text = str(rate)
	
	var dps = (damage * rate) / 60
	$VBoxContainer/HBoxContainer/Control/MarginContainer/VBoxContainer/DPS/Value.text = str(dps)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func close():
	
	emit_signal("closed", self)
	
