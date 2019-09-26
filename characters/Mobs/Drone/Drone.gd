extends "res://characters/Mobs/Mob.gd"

const Bullet = preload("res://objects/projectiles/Bullet/Bullet.tscn")

export(float) var distance_min = 2.5 # Distance minimum qu'il doit y avoir entre le joueur et le drone lorsque le drone attaque
export(float) var distance_max = 3 # Distance maximum qu'il doit y avoir entre le joueur et le drone lorsque le drone attaque
export(float) var speed_change_dir_min = 3 # Temps minimum que doit attendre le drone pour changer de direction (en secondes)
export(float) var speed_change_dir_max = 5 # Temps maximum que doit attendre le drone pour changer de direction (en secondes)
export(float) var distance_collision = 1 # Longueur du rayon du ray tracing pour détecter les collisions avec la map
export(float) var prepare_duration = 3 #Temps que met le drone pour se "préparer" avant de foncer sur le joueur (en secondes)
export(float) var speed = 2 # Vitesse du drone
export(float) var speed_charge = 5 # Vitesse du drone quand il charge
export(float) var attack_rate = 1 # Nombre de tirs du drone (par secondes)
export(int) var health_max = 10 # Nombre de vies du drone
export(float) var health_destruction = 0.2 # Pourcentage appliqué à health_max pour déterminer en dessous de combien de vies le drone s'auto detruit

enum state {
	SEARCH_TARGET,
	MOVE_FORWARD,
	MOVE_BACKWARD,
	WAIT,
	PREPARE,
	CHARGE
}

enum direction {
	UP,
	LEFT,
	DOWN,
	RIGHT
}

const OFFSET_Y = 1.2 # Equivaut à la moitié de la hauteur du joueur

var anim_state_machine
var current_state
var current_direction
var position
var velocity : Vector2
var attack_speed = 1 / attack_rate
var attack_timer
var change_dir_speed
var change_dir_timer
var target_visible : bool
var timer_prepare
var destruction : bool = false

# Returns the angle between two points.
func get_angle(x1,y1,x2,y2) -> float:
	return atan2(y2-y1, x2-x1)



# Returns the distance between two points.
func get_dist(x1,y1,x2,y2) -> float:
	return pow(pow(x2-x1,2)+pow(y2-y1,2),0.5)



func change_direction() -> void:
	var potential_direction = [direction.UP, direction.DOWN, direction.LEFT, direction.RIGHT] # Ensemble des directions
	var keep_direction = false
	var newDirection
	
	change_dir_speed = floor(rand_range(speed_change_dir_min, speed_change_dir_max))
	
	while keep_direction == false:
		keep_direction = true
		
		var rndNumber = floor(rand_range(0,potential_direction.size()))
		newDirection = potential_direction[rndNumber]
		
		if newDirection == current_direction: # Si la nouvelle direction est identique à l'ancienne, on la supprime de la liste des directions possibles et on recommence l'algo
			keep_direction = false
			potential_direction.remove(rndNumber)
		else:
			var destination = position
			if newDirection == direction.UP:
				destination = destination + Vector3(0, distance_collision, 0)
			elif newDirection == direction.LEFT:
				destination = destination + Vector3(-distance_collision, 0, 0)
			elif newDirection == direction.DOWN:
				destination = destination + Vector3(0, -distance_collision, 0)
			else: # newDirection == direction.RIGHT
				destination = destination + Vector3(distance_collision, 0, 0)
			
			var space_state = get_world().direct_space_state
			var result_collision = space_state.intersect_ray(position, destination, [self], collision_mask) 
			
			if result_collision: # Si la nouvelle direction provoque une "collision" (par ray casting), on recommence l'algo et on la supprime de la liste des directions possibles
				keep_direction = false
				potential_direction.remove(rndNumber)
		
	current_direction = newDirection



# Called when the node enters the scene tree for the first time.
func _ready():
	var anim_state_machine = $MobDrone/AnimationTree["parameters/StateMachine/playback"]
	anim_state_machine.start("Idle")
	
	current_state = state.SEARCH_TARGET
	velocity = Vector2.ZERO
	position = global_transform.origin
	attack_timer = attack_speed
	target_visible = false
	
	change_dir_speed = floor(rand_range(speed_change_dir_min, speed_change_dir_max))
	
	change_direction()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $CombatStats.health == 0:
		return
	
	var dist
	
	position = global_transform.origin
	var target_position
	
	if not targets.empty():
		current_target = targets[0]
	
	if current_target != null:
		target_position = Vector2(current_target.global_transform.origin.x, current_target.global_transform.origin.y + OFFSET_Y)
		dist = get_dist(position.x, position.y, target_position.x, target_position.y)
	else:
		current_state = state.SEARCH_TARGET
		
	
	################ IA ################
	if current_state == state.SEARCH_TARGET:
		
		change_dir_speed = change_dir_speed - delta
		if change_dir_speed <= 0:
			change_direction()
		
		if current_direction == direction.UP:
			velocity = Vector2(0, speed)
		elif current_direction == direction.LEFT:
			velocity = Vector2(-speed, 0)
		elif current_direction == direction.DOWN:
			velocity = Vector2(0, -speed)
		else: # current_direction == direction.RIGHT
			velocity = Vector2(speed, 0)
		
		if target_visible:
			current_state = state.MOVE_FORWARD
		
	elif current_state == state.MOVE_FORWARD:
		
		var angle = get_angle(position.x, position.y, target_position.x, target_position.y)
		velocity = Vector2(cos(angle) * speed, sin(angle) * speed)
		
		if abs(dist) < distance_max:
			current_state = state.WAIT

	elif current_state == state.MOVE_BACKWARD:

		var angle = get_angle(position.x, position.y, target_position.x, target_position.y)
		velocity = Vector2(cos(angle) * -speed, sin(angle) * -speed)

		if abs(dist) > distance_min:
			current_state = state.WAIT

	elif current_state == state.WAIT:

		velocity = Vector2.ZERO

		if abs(dist) >= distance_max:
			current_state = state.MOVE_FORWARD
		elif abs(dist) <= distance_min:
			current_state = state.MOVE_BACKWARD
		
	elif current_state == state.PREPARE:
		
		velocity = Vector2.ZERO
		
		timer_prepare = timer_prepare - delta
		if timer_prepare <= 0:
			current_state = state.CHARGE
			var angle = get_angle(position.x, position.y, target_position.x, target_position.y)
			velocity = Vector2(cos(angle) * speed_charge, sin(angle) * speed_charge)
		
	elif current_state == state.CHARGE:
		
		if dist <= 0.75:
			_on_RemoveTimer_timeout()
		
		pass
	
	if destruction == false and $CombatStats.health <= health_max * health_destruction:
		current_state = state.PREPARE
		timer_prepare = prepare_duration
		destruction = true
	
	if current_target != null and target_visible and destruction == false:
			attack_timer -= delta
			if attack_timer <= 0:
				$MobDrone/AnimationTree.set("parameters/Attack/active", true)
				attack_timer = attack_speed
				attack()
	
	move_and_slide(Vector3(velocity.x, velocity.y, 0))



func attack():
	var bullet = Bullet.instance()
	var root_node = get_tree().get_root().get_child(0)
	root_node.add_child(bullet)
	
	bullet.global_transform.origin = $AttackPosition.global_transform.origin
	
	# Modification des positions utilisées pour diriger le tir
	var target_position = current_target.global_transform.origin
	var new_position_target = Vector3(target_position.x, target_position.y + OFFSET_Y, target_position.z)
	var new_position # du drone
	if target_position.x > position.x:
		new_position = Vector3(self.global_transform.origin.x + 0.7, self.global_transform.origin.y, 0)
	else:
		new_position = Vector3(self.global_transform.origin.x - 0.7, self.global_transform.origin.y, 0)
		
	bullet.direction = (new_position_target - new_position).normalized()



func _physics_process(delta):
	if $CombatStats.health > 0:
		if current_target:
			face_to(current_target.global_transform.origin)
	else:
		move_and_slide(Vector3.DOWN * 5)
	
	var space_state = get_world().direct_space_state
	
	# Collision avec la map
	if current_state == state.SEARCH_TARGET:
		var destination = position
		
		if current_direction == direction.UP:
			destination = destination + Vector3(0, distance_collision, 0)
		elif current_direction == direction.LEFT:
			destination = destination + Vector3(-distance_collision, 0, 0)
		elif current_direction == direction.DOWN:
			destination = destination + Vector3(0, -distance_collision, 0)
		else: # current_direction == direction.RIGHT
			destination = destination + Vector3(distance_collision, 0, 0)
		
		var result_collision = space_state.intersect_ray(position, destination, [self], collision_mask) 
		
		if result_collision: # Si il y a "collision"
			change_direction()
	
	# Vérifie si le joueur est "visible" par le drone
	if current_target != null:
		var target_position = current_target.global_transform.origin

		# Ray-casting
		var result_target_upup = space_state.intersect_ray(position, target_position + Vector3(0, 1.95, 0), [self], collision_mask) # Sommet du joueur
		var result_target_up = space_state.intersect_ray(position, target_position + Vector3(0, 1.6, 0), [self], collision_mask) # Cou du joueur
		var result_target_center = space_state.intersect_ray(position, target_position + Vector3(0, 1.1, 0), [self], collision_mask) # Centre du joueur
		var result_target_down = space_state.intersect_ray(position, target_position + Vector3(0, 0.60, 0), [self], collision_mask) # Jambe du joueur
		var result_target_downdown = space_state.intersect_ray(position, target_position, [self], collision_mask) # Pied du joueur
		
		if not result_target_upup or not result_target_up or not result_target_center or not result_target_down or not result_target_downdown:
			target_visible = true
		else:
			if current_state != state.CHARGE and current_state != state.PREPARE:
				current_state = state.SEARCH_TARGET
			
			target_visible = false



func _on_CombatStats_damage_taken():
	pass # Replace with function body.



func _on_CombatStats_health_depleted():
	self.set_collision_layer(0x00)
	self.set_collision_mask(0x01)
	
	$RemoveTimer.start()



func _on_RemoveTimer_timeout():
	queue_free()
