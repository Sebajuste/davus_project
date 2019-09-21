extends "res://characters/Mobs/Mob.gd"

const Bullet = preload("res://objects/projectiles/Bullet/Bullet.tscn")

enum state { 
	CHOOSE_TARGET, 
	MOVE_FORWARD, 
	MOVE_BACKWARD,
	WAIT
}

var anim_state_machine
var current_state
var position = global_transform.origin
var vx = 0
var vy = 0

# Returns the angle between two points.
func get_angle(x1,y1,x2,y2) -> float:
	return atan2(y2-y1, x2-x1)

# Returns the distance between two points.
func get_dist(x1,y1,x2,y2) -> float:
	return pow(pow(x2-x1,2)+pow(y2-y1,2),0.5)

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = state.CHOOSE_TARGET
	
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
	
	position = global_transform.origin
	
	# AI
	if current_state == state.CHOOSE_TARGET:
		
		if not targets.empty():
			current_target = targets[0]
			current_state = state.MOVE_FORWARD
		
	elif current_state == state.MOVE_FORWARD:
		
		var target_position = current_target.global_transform.origin
		var angle = get_angle(position.x, position.y, target_position.x, target_position.y)
		vx = cos(angle) * 2
		vy = sin(angle) * 2
		
		var dist = get_dist(position.x, position.y, target_position.x, target_position.y)
		if abs(dist) <= 3:
			current_state = state.WAIT
	
	elif current_state == state.WAIT:
		
		vx = 0
		vy = 0
		
		var target_position = current_target.global_transform.origin
		var dist = get_dist(position.x, position.y, target_position.x, target_position.y)
		if abs(dist) > 3:
			current_state = state.MOVE_FORWARD
		elif abs(dist) <= 2.5:
			current_state = state.MOVE_BACKWARD
		
		
	elif current_state == state.MOVE_BACKWARD:
		
		var target_position = current_target.global_transform.origin
		var angle = get_angle(position.x, position.y, target_position.x, target_position.y)
		vx = -(cos(angle) * 3)
		vy = -(sin(angle) * 3)
		
		var dist = get_dist(position.x, position.y, target_position.x, target_position.y)
		if abs(dist) > 2.5:
			current_state = state.WAIT
	
	move_and_slide(Vector3(vx, vy, 0))


func _physics_process(delta):
	
	if $CombatStats.health > 0:
		if current_target:
			face_to(current_target.global_transform.origin)
	else:
		
		move_and_slide(Vector3.DOWN * 5)
		
		pass



func attack():
	var bullet = Bullet.instance()
	var root_node = get_tree().get_root().get_child(0)
	root_node.add_child(bullet)
	
	bullet.global_transform.origin = $AttachPosition.global_transform.origin
	bullet.direction = (current_target.global_transform.origin - self.global_transform.origin).normalized()



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
	
