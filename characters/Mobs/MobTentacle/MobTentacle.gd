extends "res://characters/Mobs/Mob.gd"

var anim_state_machine


var _current_target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_state_machine = $MobTentacle/AnimationTree["parameters/StateMachine/playback"]
	face_to(self.global_transform.origin + Vector3(1, 0, 0) )
	anim_state_machine.start("Idle")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $CombatStats.health == 0:
		return
	
	if not targets.empty():
		var target = targets[0]
		_current_target = target
		
		var distance = target.global_transform.origin - self.global_transform.origin
		
		if distance.length() < 2.5:
			anim_state_machine.travel("Attack")
		
	else:
		_current_target = null


func _physics_process(delta):
	
	if $CombatStats.health == 0:
		return
	
	if _current_target:
		face_to(_current_target.global_transform.origin)


func face_to(position: Vector3):
	var look_pos := self.global_transform.origin
	look_pos.x = position.x
	if global_transform.origin != look_pos:
		var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
		global_transform = Transform(rotTransform.basis, global_transform.origin)


func move_to(position: Vector3):
	pass # Do nothing. tentacle cannot move


func _on_CombatStats_health_depleted():
	$AttackSound.stop()
	$DieSound.play()
	anim_state_machine.travel("Death")
	self.set_collision_layer(0x00)
	self.set_collision_mask(0x00)
	$RemoveTimer.start()


func _on_CombatStats_damage_taken():
	
	$MobTentacle/AnimationTree.set("parameters/Hit/active", true)
	
	pass # Replace with function body.


func _on_RemoveTimer_timeout():
	
	queue_free()
	
