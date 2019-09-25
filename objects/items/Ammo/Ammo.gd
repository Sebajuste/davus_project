extends Spatial

const TYPE = "ammo"

export(String, "Fire", "Ice", "Normal") var ammo_type := "Normal"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	match ammo_type:
		"Fire":
			$Spatial/Normal.visible = false
			$Spatial/Ice.visible = false
		"Ice":
			$Spatial/Normal.visible = false
			$Spatial/Fire.visible = false
		_:
			$Spatial/Ice.visible = false
			$Spatial/Fire.visible = false
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	
	if body.is_in_group("player") and body.has_method("give_item"):
		var item = Item.new()
		item.type = TYPE
		
		item.properties["ammo_type"] = ammo_type
		
		body.give_item(item)
		
		queue_free()
	pass # Replace with function body.
