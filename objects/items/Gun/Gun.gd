extends Spatial

const TYPE = "gun"

export var damage := 1.0
export var rate := 60

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	
	if body.is_in_group("player") and body.has_method("give_item"):
		
		var item = Item.new()
		item.type = TYPE
		
		item.properties["damage"] = damage
		item.properties["rate"] = rate
		
		body.give_item(item)
		queue_free()
	
	pass # Replace with function body.
