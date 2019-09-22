extends Spatial

const TYPE = "gun"

export(Dictionary) var item := {
	"damage": 1.0,
	"rate": 60
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	
	if body.is_in_group("player"):
		item.type = TYPE
		body.give_object(item)
		queue_free()
	
	pass # Replace with function body.
