extends "res://characters/Mobs/Mob.gd"

const Bullet = preload("res://objects/projectiles/Bullet/Bullet.tscn")

export(float) var distance_min = 2.5 # Distance minimum qu'il doit y avoir entre le joueur et la mouche lorsque la mouche attaque
export(float) var distance_max = 3.0 # Distance maximum qu'il doit y avoir entre le joueur et la mouche lorsque la mouche attaque
export(float) var speed = 3.0 # Vitesse de la mouche
export(float) var attack_rate = 1.0 # Nombre de tirs de la mouche par secondes

enum state { 
	CHOOSE_TARGET, 
	MOVE_FORWARD, 
	MOVE_BACKWARD,
	ATTACK
}

const OFFSET_Y = 1 # Equivaut à la moitié de la hauteur du joueur

var anim_state_machine
var current_state
onready var position = global_transform.origin # position de la mouche
var velocity = Vector2(0,0)
var attack_speed = 1 / attack_rate # Temps de "rechargement" de la mouche (en secondes) / calculé en fonction du Nombre de tirs par secondes
var attack_timer = 0
var sinus = 0



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
	anim_state_machine.start("Idle")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $CombatStats.health == 0:
		return
	
	if current_state != state.ATTACK:
		sinus = sinus + 0.05
		if sinus >= 2*PI:
			sinus = 0
		self.global_transform.origin = Vector3(self.global_transform.origin.x, self.global_transform.origin.y + sin(sinus)/250, self.global_transform.origin.z)
	
	position = global_transform.origin # Position de la mouche
	var target_position
	var dist
	
	if current_target != null:
		target_position = Vector2(current_target.global_transform.origin.x, current_target.global_transform.origin.y + OFFSET_Y)
		dist = get_dist(position.x, position.y, target_position.x, target_position.y)
	else:
		current_state = state.CHOOSE_TARGET
	
	################ AI ################
	if current_state == state.CHOOSE_TARGET:
		
		if not targets.empty():
			current_target = targets[0]
			current_state = state.MOVE_FORWARD
		
	elif current_state == state.MOVE_FORWARD:
		
		var angle = get_angle(position.x, position.y, target_position.x, target_position.y)
		velocity = Vector2(cos(angle) * speed, sin(angle) * speed)
		
		if abs(dist) <= distance_max:
			current_state = state.ATTACK
			attack_timer = attack_speed
		
	elif current_state == state.ATTACK:
		
		attack_timer -= delta
		if attack_timer <= 0:
			anim_state_machine.travel("Attack")
			attack_timer = attack_speed
			attack()
		
		velocity = Vector2.ZERO
		
		if abs(dist) > distance_max:
			current_state = state.MOVE_FORWARD
		elif abs(dist) <= distance_min:
			current_state = state.MOVE_BACKWARD
		
	elif current_state == state.MOVE_BACKWARD:
		
		var angle = get_angle(position.x, position.y, target_position.x, target_position.y)
		velocity = Vector2(-(cos(angle) * speed), -(sin(angle) * speed))
		
		if abs(dist) > distance_min:
			current_state = state.ATTACK
	
	move_and_slide(Vector3(velocity.x, velocity.y, 0))



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
	
	bullet.global_transform.origin = $AttackPosition.global_transform.origin
	
	# Modification des positions utilisées pour diriger le tir
	var target_position = current_target.global_transform.origin
	var new_position_target = Vector3(target_position.x, target_position.y + OFFSET_Y, target_position.z)
	var new_position # de la mouche
	if target_position.x > position.x:
		new_position = Vector3(self.global_transform.origin.x + 1, self.global_transform.origin.y, 0)
	else:
		new_position = Vector3(self.global_transform.origin.x - 1, self.global_transform.origin.y, 0)
		
	bullet.direction = (new_position_target - new_position).normalized()



func _on_CombatStats_damage_taken():
	
	$FlyModel/AnimationTree.set("parameters/Hit/active", true)
	



func _on_CombatStats_health_depleted():
	
	$FlySound.stop()
	$DieSound.play()
	anim_state_machine.travel("Death")
	self.set_collision_layer(0x00)
	self.set_collision_mask(0x01)
	
	$RemoveTimer.start()
	


func _on_RemoveTimer_timeout():
	
	queue_free()
	
