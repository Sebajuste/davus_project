extends KinematicBody


export var max_life := 100
export var attack := 20

var life: int = 0


var _targets := []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	life = max_life
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func move_to(position: Vector3):
	pass


func _on_Detection_body_entered(body):
	
	print("detected")
	
	_targets.append(body)
	
	pass # Replace with function body.


func _on_Detection_body_exited(body):
	var index = _targets.find(body)
	if index >= 0:
		_targets.remove(index)
	
