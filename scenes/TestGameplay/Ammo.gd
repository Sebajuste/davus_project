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


func _on_AmmoHandler_ammo_selected(ammo: Item):
	
	match ammo.properties["ammo_type"]:
		"Normal":
			$Normal.visible = true
			$Fire.visible = false
			$Ice.visible = false
		"Fire":
			$Normal.visible = false
			$Fire.visible = true
			$Ice.visible = false
		"Ice":
			$Normal.visible = false
			$Fire.visible = false
			$Ice.visible = true
	
	#$Value.text = ammo.properties["ammo_type"]
	
	pass # Replace with function body.
