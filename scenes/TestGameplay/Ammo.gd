extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AmmoHandler_ammo_selected(ammo):
	print("ammo: ", ammo)
	$Value.text = ammo.ammo_type
	
	pass # Replace with function body.
