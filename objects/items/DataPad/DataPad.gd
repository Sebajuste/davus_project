extends Spatial


export(String, MULTILINE) var message := ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use(actor) -> bool:
	#modal_message.open_model_message(message)
	return true
