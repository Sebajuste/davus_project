extends Spatial

export var locked := false


var near_object := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var state_machines = $AnimationTree["parameters/playback"]
	if state_machines.is_playing():
		state_machines.travel("closed")
	else:
		state_machines.start("closed")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	
	near_object += 1
	
	if not locked:
		var state_machines = $AnimationTree["parameters/playback"]
		if state_machines.is_playing():
			state_machines.travel("opened")
		else:
			state_machines.start("opened")
	
	pass # Replace with function body.


func _on_Area_body_exited(body):
	
	near_object -= 1
	
	if near_object == 0:
		var state_machines = $AnimationTree["parameters/playback"]
		if state_machines.is_playing():
			state_machines.travel("closed")
		else:
			state_machines.start("closed")
	
	pass # Replace with function body.
