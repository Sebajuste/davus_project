extends "res://characters/Mobs/Mob.gd"

const Bullet = preload("res://objects/projectiles/Bullet/Bullet.tscn")

export(float) var speed_complete_loading = 5 # Temps de rechargement entre deux salves (en secondes)
export(float) var speed_reloading = 0.6 # Temps de rechargements entre deux tirs (en secondes)
export(int) var nb_shoot = 5 # Nombre de tirs par salves
export(float) var speed_rotation_idle = 0.5 # Vitesse de rotation de la tête de la tourelle lorsqu'elle cherche une cible (en degrés)
export(float) var speed_rotation_aim = 1.5 # Vitesse de rotation de la tête de la tourelle lorsqu'elle doit viser sa cible (en degrés)
export(int) var wait_duration_min = 3 # Temps minimum que doit attendre la tourelle (en secondes)
export(int) var wait_duration_max = 6 # Temps maximum que doit attendre la tourelle (en secondes)

enum state {
	WAIT,
	ROTATE,
	SHOOT
}

enum direction {
	LEFT,
	RIGHT
}

const OFFSET_Y = 1.2 # Equivaut à la moitié de la hauteur du joueur

var position
var current_state
var timer_complete_loading
var timer_reloading
var timer_wait
var shoot_left
var target_visible
var angle_rotation = 270
var old_angle_rotation = 270
var rotate_direction
var look_at_destination # Direction vers laquelle doit regarder la tourelle après avoir effectuer une rotation
var speed_rotation



func get_dist(x1,y1,x2,y2) -> float:
	return pow(pow(x2-x1,2)+pow(y2-y1,2),0.5)



# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = state.WAIT
	shoot_left = nb_shoot
	timer_complete_loading = 1
	timer_reloading = 0
	timer_wait = wait_duration_min
	look_at_destination = direction.LEFT
	speed_rotation = speed_rotation_idle



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $CombatStats.health == 0:
		queue_free()
		return
	
	position = global_transform.origin
	
	if not targets.empty():
		current_target = targets[0]
	
	if current_state == state.WAIT:
		
		timer_wait = timer_wait - delta
		if timer_wait <= 0:
			timer_wait = rand_range(wait_duration_min, wait_duration_max)
			current_state = state.ROTATE
			speed_rotation = speed_rotation_idle
			
			var rndNumber = floor(rand_range(1,3))
			if rndNumber == 1:
				rotate_direction = direction.LEFT
			else:
				rotate_direction = direction.RIGHT
			
			if look_at_destination == direction.LEFT:
				look_at_destination = direction.RIGHT
			else:
				look_at_destination = direction.LEFT
		
	elif current_state == state.ROTATE:
		
		if rotate_direction == direction.RIGHT:
			angle_rotation = angle_rotation + speed_rotation
			if angle_rotation >= 360:
				angle_rotation = 0
			
			if look_at_destination == direction.LEFT:
				if angle_rotation >= 270:
					angle_rotation = 270
					current_state = state.WAIT
			else:
				if angle_rotation >= 90 and old_angle_rotation < 90:
					angle_rotation = 90
					current_state = state.WAIT
		else:
			angle_rotation = angle_rotation - speed_rotation
			if angle_rotation <= 0:
				angle_rotation = 360
			
			if look_at_destination == direction.LEFT:
				if angle_rotation <= 270 and old_angle_rotation > 270:
					angle_rotation = 270
					current_state = state.WAIT
			else:
				if angle_rotation <= 90:
					angle_rotation = 90
					current_state = state.WAIT
		
		var head_position = $MobTurret/Turret/Head.global_transform.origin # Position de la tête de la tourelle
		# Angle appliqué à la tête de la tourelle
		$MobTurret/Turret/Head.look_at_from_position(head_position, Vector3(head_position.x + cos(deg2rad(angle_rotation)), head_position.y, head_position.z + sin(deg2rad(angle_rotation))), Vector3.UP)
		$MobTurret/Turret/Head.orthonormalize() # Corrige les erreurs d'angle
		
		if target_visible and ((look_at_destination == direction.LEFT and angle_rotation == 270) or (look_at_destination == direction.RIGHT and angle_rotation == 90)) :
			current_state = state.SHOOT
		
		old_angle_rotation = angle_rotation
		
	elif current_state == state.SHOOT:
		
		var target_position = current_target.global_transform.origin
		if target_position.x < position.x and look_at_destination == direction.RIGHT:
			current_state = state.ROTATE
			look_at_destination = direction.LEFT
		elif target_position.x > position.x and look_at_destination == direction.LEFT:
			current_state = state.ROTATE
			look_at_destination = direction.RIGHT
		
		if target_visible == false:
			current_state = state.WAIT
		
		timer_complete_loading = timer_complete_loading - delta
		if timer_complete_loading <= 0:
			timer_reloading = timer_reloading - delta
			
			if timer_reloading <= 0:
				attack()
				shoot_left = shoot_left - 1
				timer_reloading = speed_reloading
				
				if shoot_left <= 0:
					timer_complete_loading = speed_complete_loading
					shoot_left = nb_shoot
			



func attack():
	var bullet = Bullet.instance()
	var root_node = get_tree().get_root().get_child(0)
	root_node.add_child(bullet)
	
	if look_at_destination == direction.LEFT:
		bullet.global_transform.origin = $AttackPositionLeft.global_transform.origin
	else:
		bullet.global_transform.origin = $AttackPositionRight.global_transform.origin
	
	# Modification des positions utilisées pour diriger le tir
	var target_position = current_target.global_transform.origin
	var new_position_target = Vector3(target_position.x, target_position.y + OFFSET_Y, target_position.z)
	var position_head = $MobTurret/Turret/Head.global_transform.origin 
	var new_position # de la tourelle
	if target_position.x > position.x:
		new_position = Vector3(position_head.x + OFFSET_Y, position_head.y, 0)
	else:
		new_position = Vector3(position_head.x - OFFSET_Y, position_head.y, 0)
	
	bullet.direction = (new_position_target - new_position).normalized()



func _physics_process(delta):
	var space_state = get_world().direct_space_state
#
#	# Vérifie si le joueur est "visible" par le drone
	if current_target != null:
		var target_position = current_target.global_transform.origin
		var head_position = $MobTurret/Turret/Head.global_transform.origin
		
		# Ray-casting
		var result_target_upup = space_state.intersect_ray(head_position, target_position + Vector3(0, 1.95, 0), [self], collision_mask) # Sommet du joueur
		var result_target_up = space_state.intersect_ray(head_position, target_position + Vector3(0, 1.6, 0), [self], collision_mask) # Cou du joueur
		var result_target_center = space_state.intersect_ray(head_position, target_position + Vector3(0, 1.1, 0), [self], collision_mask) # Centre du joueur
		var result_target_down = space_state.intersect_ray(head_position, target_position + Vector3(0, 0.60, 0), [self], collision_mask) # Jambe du joueur
		var result_target_downdown = space_state.intersect_ray(head_position, target_position, [self], collision_mask) # Pied du joueur

		if not result_target_upup or not result_target_up or not result_target_center or not result_target_down or not result_target_downdown:
			target_visible = true
			
			if current_state != state.SHOOT:
				current_state = state.ROTATE
				speed_rotation = speed_rotation_aim
				
				if target_position.x < position.x and angle_rotation != 270:
					look_at_destination = direction.LEFT
					if angle_rotation > 90 and angle_rotation < 270:
						rotate_direction = direction.RIGHT
					else:
						rotate_direction = direction.LEFT
				else:
					look_at_destination = direction.RIGHT
					if angle_rotation > 90 and angle_rotation < 270:
						rotate_direction = direction.LEFT
					else:
						rotate_direction = direction.RIGHT
		else:
			target_visible = false



func _on_CombatStats_damage_taken():
	pass # Replace with function body.



func _on_CombatStats_health_depleted():
	self.set_collision_layer(0x00)
	self.set_collision_mask(0x01)
