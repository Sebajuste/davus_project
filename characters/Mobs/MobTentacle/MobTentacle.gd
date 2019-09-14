extends KinematicBody

onready var anim_state_machine = $MobTentacle/AnimationTree["parameters/playback"]


var _targets := []

var _current_target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not _targets.empty():
		var target = _targets[0]
		_current_target = target
		
		var distance = target.global_transform.origin - self.global_transform.origin
		
		if distance.length() < 2.0:
			if anim_state_machine.is_playing():
				anim_state_machine.travel("Attack")
			else:
				anim_state_machine.start("Attack")
			
	else:
		_current_target = null


func _physics_process(delta):
	
	if _current_target:
		var look_pos := self.global_transform.origin
		look_pos.x = _current_target.global_transform.origin.x
		
		var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
		global_transform = Transform(rotTransform.basis, global_transform.origin)


func move_to(position: Vector3):
	pass # Do nothing. tentacle cannot move


func _on_Detection_body_entered(body):
	_targets.append(body)


func _on_Detection_body_exited(body):
	var index = _targets.find(body)
	if index >= 0:
		_targets.remove(index)


func _on_CombatStats_health_depleted():
	queue_free()
