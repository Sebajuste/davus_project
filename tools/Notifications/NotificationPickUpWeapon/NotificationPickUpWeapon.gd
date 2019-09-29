extends Panel


signal closed(notification)


export var damage : int = 0
export var rate : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$VBoxContainer/HBoxContainer/Control/MarginContainer/VBoxContainer/Damage/Value.text = str(damage)
	$VBoxContainer/HBoxContainer/Control/MarginContainer/VBoxContainer/FireRate/Value.text = str(rate)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func close():
	
	emit_signal("closed", self)
	
