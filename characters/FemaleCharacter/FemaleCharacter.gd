extends KinematicBody

const GRAVITY := 9.8
const MAX_JUMP := 1
const MAX_FALL_SPEED := -20.0
const ACCELERATION = 3
const DE_ACCELERATION = 7
const AIR_ACCELERATION = 1
const AIR_DE_ACCELERATION = 3


signal died
signal health_changed(health, max_health)


export var max_speed := 10


var velocity := Vector3()


var _fall_time := 0.0
var _anim_update := false
var _jump_event := false
var _jump_count := MAX_JUMP
var _jumping := false
var _air_time := 0.0
var _floor_time := 0.0
var _walk_sound_ready := true
var _look_dir = Vector3()
var _lock_dir := false
var _ennemies := []

var _notification_message = NotificationMessageFactory.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	emit_signal("health_changed", $CombatStats.health, $CombatStats.max_health)
	
	$AnimationTree.set("parameters/StateMachine/Locomotion/TimeScale/scale", -0.2)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#_jump_event = false
	
	if $CombatStats.health == 0:
		return
	
	
	_look_dir = Vector3()
	
	if controller.type == controller.Type.MOUSE_KEYBOARD:
		_look_dir = ($CursorSelector.get_target_pos() - (global_transform.origin + Vector3(0, 1, 0)))
	elif controller.type == controller.Type.GAMEPAD:
		var look_dir = Vector3()
		look_dir += Vector3.RIGHT * Input.get_action_strength("look_right")
		look_dir += Vector3.LEFT * Input.get_action_strength("look_left")
		look_dir += Vector3.UP * Input.get_action_strength("look_up")
		look_dir += Vector3.DOWN * Input.get_action_strength("look_down")
		if look_dir.length() > 0.2:
			_look_dir = look_dir * 5
			_lock_dir = true
		else:
			_lock_dir = false
	
	if $WeaponHandler.aiming and _air_time < 0.1 and _floor_time > 0.2:
		
		if controller.type == controller.Type.MOUSE_KEYBOARD:
			$WeaponHandler.target = $CursorSelector.get_target_pos()
		elif controller.type == controller.Type.GAMEPAD:
			var look_dir = _look_dir
			if not _lock_dir:
				look_dir = Vector3(global_transform.basis.z.x, 0, 0)
			
			var target = _get_aimbot_target(global_transform.origin + Vector3(0, 1.2, 0), look_dir)
			if target != null:
				$WeaponHandler.target = target.global_transform.origin
			else:
				$WeaponHandler.target = global_transform.origin + look_dir * 100
			
		
		if $WeaponHandler.valid_target:
				$WeaponHandler.shoot_ready = true
	else:
		$WeaponHandler.shoot_ready = false


func _physics_process(delta):
	
	if $WeaponHandler.aiming and $WeaponHandler.valid_target and $WeaponHandler.shoot_ready and controller.type == controller.Type.GAMEPAD:
		var weapon = $WeaponHandler.get_weapon()
		if weapon != null:
			$LaserPointer.visible = true
			$LaserPointer.weapon_pos = weapon.global_transform.origin
			$LaserPointer.target_pos = $WeaponHandler.target
	else:
		$LaserPointer.visible = false
	
	
	
	var move_dir = Vector3()
	
	if $CombatStats.health > 0:
		if Input.is_action_pressed("move_right"):
			move_dir += Vector3.RIGHT
	
		if Input.is_action_pressed("move_left"):
			move_dir += Vector3.LEFT
	
	move_dir = move_dir.normalized()
	
	velocity.y += delta * -GRAVITY * 2
	
	if _jump_event:
		_jump_event = false
		if not is_falling() and _jump_count > 0:
			_jump_count -= 1
			_jumping = true
			_play_anim("jump_run_in_place", true)
			velocity.y = 10
			pass
	
	var hv = velocity
	hv.y = 0
	
	var accel = DE_ACCELERATION
	if move_dir.dot(hv) > 0:
		accel = ACCELERATION
	
	var new_pos = move_dir * max_speed
	
	if is_on_floor():
		hv = hv.linear_interpolate(new_pos, accel * delta)
	else:
		accel = AIR_DE_ACCELERATION
		if move_dir.dot(hv) > 0:
			accel = AIR_ACCELERATION
		new_pos = move_dir * max_speed
		hv = hv.linear_interpolate(new_pos, accel * delta)
	
	velocity.x = hv.x
	velocity.z = hv.z
	
	velocity = move_and_slide( velocity , Vector3.UP )
	global_transform.origin.z = 0
	velocity.y = max(MAX_FALL_SPEED, velocity.y)
	
	
	if $CombatStats.health == 0:
		return
	
	if is_on_floor():
		_jumping = false
		_jump_count = MAX_JUMP
		_air_time = 0.0
		_floor_time += delta
	else:
		_floor_time = 0.0
		_air_time += delta
	
	if is_on_floor() or velocity.y > 0:
		_fall_time = 0.0
	else:
		_fall_time += delta
	
	if $WeaponHandler.aiming:
		if controller.type == Controller.Type.GAMEPAD and not _lock_dir:
			var look_pos = global_transform.origin - move_dir
			if global_transform.origin != look_pos:
				var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
				global_transform = Transform(rotTransform.basis, global_transform.origin)
				global_transform.origin.z = 0
			
		else:
			var look_pos = global_transform.origin
			look_pos.x -= _look_dir.x
			if global_transform.origin != look_pos:
				var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
				global_transform = Transform(rotTransform.basis, global_transform.origin)
				global_transform.origin.z = 0
	else:
		var look_pos = global_transform.origin - move_dir
		if global_transform.origin != look_pos:
			var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
			global_transform = Transform(rotTransform.basis, global_transform.origin)
			global_transform.origin.z = 0
	
	if is_on_floor():
		if abs(velocity.x) > 0.5:
			_play_anim("Locomotion")
			
			if velocity.normalized().dot(global_transform.basis.z.normalized()) < 0.0:
				$AnimationTree.set("parameters/StateMachine/Locomotion/Backward/current", 1)
			else:
				$AnimationTree.set("parameters/StateMachine/Locomotion/Backward/current", 0)
			
			if not $WalkSound.playing and _walk_sound_ready:
				$WalkSound.pitch_scale = rand_range(0.8, 1.2)
				$WalkSound.play()
				$WalkTimer.start()
				_walk_sound_ready = false
		else:
			_play_anim("Idle")
			$WalkSound.stop()
	else:
		_play_anim("Falling")
		$WalkSound.stop()
	
	_anim_update = false


func _input(event) -> void:
	
	if $CombatStats.health == 0:
		return
	
	if Input.is_action_just_pressed("jump"):
		#_jump_action = true
		_jump_event = true
	#if Input.is_action_just_released("jump"):
	#	_jump_action =  false
	
	if Input.is_action_just_pressed("use"):
		var usable = $UsableArea.get_usable()
		if usable != null and usable.has_method("use"):
			usable.use(self)


func is_aiming() -> bool:
	return $WeaponHandler.aiming

func get_items() -> Array:
	return $Inventory.get_items()


func give_item(item: Item, raise_notification: bool = true) -> void:
	var added := false
	if item.type == "ammo":
		var same_ammo_type_found := false
		for inventory_item in $Inventory.get_items():
			if inventory_item.type == "ammo":
				if inventory_item.properties["ammo_type"] == item.properties["ammo_type"]:
					same_ammo_type_found = true
		if not same_ammo_type_found:
			$Inventory.add_item(item)
			added = true
	else:
		$Inventory.add_item(item)
		added = true
	
	if added and raise_notification:
		var notification = _notification_message.create_item_notification(item)
		notifications.push_notification(notification)


func remove_item(item: Item) -> bool:
	return $Inventory.remove_item(item)


func is_falling() -> bool:
	return _fall_time > 0.2


func reset() -> void:
	
	$CombatStats.heal( $CombatStats.max_health )
	


func _get_aimbot_target(from_position: Vector3, look_dir: Vector3) -> Spatial:
	var near_dot = null
	var near_distance = null
	var target = null
	for ennemy in _ennemies:
		var distance_vector : Vector3 = ennemy.global_transform.origin - from_position
		var ennemy_dir = distance_vector.normalized()
		var r = ennemy_dir.dot( look_dir.normalized())
		if r > 0.98:
			var distance = distance_vector.length()
			if near_distance == null or distance < near_distance:
				near_distance = distance
				target = ennemy
	return target


func _play_anim(name: String, force: bool = false):
	if _anim_update:
		return
	_anim_update = true
	$AnimationTree.travel(name)


func _on_WalkTimer_timeout():
	_walk_sound_ready = true


func _on_CombatStats_damage_taken():
	$AnimationTree.set("parameters/Hit/active", true)
	if controller.type == Controller.Type.GAMEPAD:
		Input.start_joy_vibration(0, 0, 0.2, 0.2)


func _on_CombatStats_health_depleted():
	
	$AnimationTree.set("parameters/Alive/current", 1)
	$WeaponHandler.shoot_ready = false
	
	emit_signal("died")


func _on_CombatStats_health_changed(new_value, old_value):
	if new_value > 0:
		$AnimationTree.set("parameters/Alive/current", 0)
	emit_signal("health_changed", new_value, $CombatStats.max_health)


func _on_Inventory_item_equiped(item):
	
	print("Equip : ", item)
	
	print("items : ", $Inventory._items )
	


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("mob"):
		_ennemies.append(body)


func _on_DetectionArea_body_exited(body):
	var index = _ennemies.find(body)
	if index != -1:
		_ennemies.remove(index)

func _on_WeaponHandler_aimed(state):
	if not state:
		$HealthRegen.start()
	else:
		$HealthRegen.stop()


func _on_HealthRegen_timeout():
	
	$CombatStats.heal( 5 )
	
