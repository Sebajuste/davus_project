extends "res://characters/Mobs/Mob.gd"

var anim_state_machine

# Called when the node enters the scene tree for the first time.
func _ready():
	
	anim_state_machine = $FlyModel/AnimationTree["parameters/StateMachine/playback"]
	if anim_state_machine.is_playing():
		anim_state_machine.travel("Idle")
	else:
		anim_state_machine.start("Idle")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $CombatStats.health == 0:
		return
	
	if not targets.empty():
		var target = targets[0]
		current_target = target
	else:
		current_target = null



func _physics_process(delta):
	
	if $CombatStats.health > 0:
		if current_target:
			face_to(current_target.global_transform.origin)
	else:
		# TODO : fall
		
		move_and_slide(Vector3.DOWN * 5)
		
		pass


func _on_CombatStats_damage_taken():
	
	$FlyModel/AnimationTree.set("parameters/Hit/active", true)
	


func _on_CombatStats_health_depleted():
	
	if anim_state_machine.is_playing():
		anim_state_machine.travel("Death")
	else:
		anim_state_machine.start("Death")
	
	self.set_collision_layer(0x00)
	self.set_collision_mask(0x01)
	
	$RemoveTimer.start()
	
	$AudioStreamPlayer3D.stop()


func _on_RemoveTimer_timeout():
	
	queue_free()
	
