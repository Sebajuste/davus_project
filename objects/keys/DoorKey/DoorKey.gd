extends Spatial


const KeyPickUpNotification = preload("res://tools/Notifications/NotificationPickUpKey/NotificationPickUpKey.tscn")


export var id_door := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body.is_in_group("player") and body.has_method("give_item"):
		var item = Item.new()
		item.type = "key"
		item.properties["id_door"] = id_door
		body.give_item(item)
		queue_free()
