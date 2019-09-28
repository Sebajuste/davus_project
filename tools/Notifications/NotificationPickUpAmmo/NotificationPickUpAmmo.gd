extends Panel


export var type := "Normal"
export var message := "" setget set_message


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/Normal.visible = false
	$VBoxContainer/HBoxContainer/Fire.visible = false
	$VBoxContainer/HBoxContainer/Ice.visible = false
	match type:
		"Normal":
			$VBoxContainer/HBoxContainer/Normal.visible = true
		"Fire":
			$VBoxContainer/HBoxContainer/Fire.visible = true
		"Ice":
			$VBoxContainer/HBoxContainer/Ice.visible = true
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_message(value):
	message = value
	$VBoxContainer/HBoxContainer/Label.text = message


func _on_Timer_timeout():
	
	queue_free()
	
