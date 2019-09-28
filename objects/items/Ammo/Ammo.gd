extends Spatial

const TYPE = "ammo"


export(String, "Fire", "Ice", "Normal") var ammo_type := "Normal"


var taken := false
var destroy_timer := 1.0


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
func _process(delta):
	if taken:
		destroy_timer -= delta
		if destroy_timer < 0.0:
			queue_free()


func _on_Area_body_entered(body):
	
	if not taken and body.is_in_group("player") and body.has_method("give_item"):
		taken = true
		var item = Item.new()
		item.type = TYPE
		
		item.properties["ammo_type"] = ammo_type
		
		body.give_item(item)
		
		$PickUpSound.play()
		visible = false
	
