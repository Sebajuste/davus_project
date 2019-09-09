extends AnimationTree

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_value(value: float):
	
	#self.set("parameters/Locomotion/blend_position", value)
	pass

func travel(anim_name: String):
	
	var state_machines = self["parameters/StateMachine/playback"]
	if state_machines.is_playing():
		state_machines.travel(anim_name)
	else:
		state_machines.start(anim_name)
