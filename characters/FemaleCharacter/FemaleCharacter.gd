extends KinematicBody

signal died

const GRAVITY := 9.8
const MAX_JUMP := 1

export var max_speed := 10

const ACCELERATION = 3
const DE_ACCELERATION = 7

const AIR_ACCELERATION = 1
const AIR_DE_ACCELERATION = 3


var velocity := Vector3()

var _fall_time := 0.0

var _anim_update := false


var _pistol_aiming := false


var _jump_event := false
var _jump_action := false
#var _jump_dir := Vector3()
var _jump_count := MAX_JUMP
var _jumping := false

var _walk_sound_ready := true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var valid_target := false
	
	if _pistol_aiming:
		
		var target_pos = $CursorSelector.get_target_pos()
		
		var bone = $Skeleton.find_bone("mixamorig_Spine2")
		
		var bone_pos = $Skeleton.get_bone_global_pose(bone).origin
		
		var cur_dir = global_transform.basis.z.normalized()
		var target_dir = (target_pos - (global_transform.origin+bone_pos)).normalized()
		
		var look_dir = Vector3()
		
		look_dir += Vector3.UP * Input.get_action_strength("look_up")
		look_dir += Vector3.DOWN * Input.get_action_strength("look_down")
		look_dir += Vector3.RIGHT * Input.get_action_strength("look_right")
		look_dir += Vector3.LEFT * Input.get_action_strength("look_left")
		
		if look_dir.length() > 0.5:
			target_dir = look_dir.normalized()
		
		var look_dot = cur_dir.dot(target_dir)
		
		if look_dot > 0.2:
			
			valid_target = true
			
			var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)
			
			if (cur_dir + target_dir).x > 0 and (cur_dir + target_dir).y < 0:
				rotation_angle = -rotation_angle
			
			if (cur_dir + target_dir).x < 0 and (cur_dir + target_dir).y > 0:
				rotation_angle = -rotation_angle
			
			var rest: Transform = $Skeleton.get_bone_pose(bone)
			var new_pose = rest.rotated(Vector3.RIGHT, rotation_angle)
			
			$Skeleton.set_bone_pose( bone, new_pose )
	
	
	_jump_event = false
	
	if $CombatStats.health == 0:
		return
	
	if Input.is_action_just_pressed("jump"):
		_jump_action = true
		_jump_event = true
	if Input.is_action_just_released("jump"):
		_jump_action =  false
	
	
	if _pistol_aiming and velocity.y < 0.1 and valid_target:
		$Equipement/WeaponHandler.shoot_ready = true
		$Equipement/WeaponHandler.target = $CursorSelector.get_target_pos()
	else:
		$Equipement/WeaponHandler.shoot_ready = false
	


func _physics_process(delta):
	
	var dir = Vector3()
	
	if $CombatStats.health > 0:
		if Input.is_action_pressed("move_right"):
			dir += Vector3.RIGHT
	
		if Input.is_action_pressed("move_left"):
			dir += Vector3.LEFT
	
	dir = dir.normalized()
	
	velocity.y += delta * -GRAVITY * 2
	
	
	if $CombatStats.health > 0 and Input.is_action_just_pressed("unsheathe"):
		_pistol_aiming = not _pistol_aiming
		if _pistol_aiming:
			$AnimationTree.set("parameters/StateMachine/Idle/Weapon/current", 1)
			$AnimationTree.set("parameters/StateMachine/Locomotion/Weapon/current", 1)
		else:
			$AnimationTree.set("parameters/StateMachine/Idle/Weapon/current", 0)
			$AnimationTree.set("parameters/StateMachine/Locomotion/Weapon/current", 0)
	
	if _jump_event:
		if not is_falling() and _jump_count > 0:
			_jump_count -= 1
			_jumping = true
			_play_anim("jump_run_in_place", true)
			velocity.y = 10
			pass
	
	var hv = velocity
	hv.y = 0
	
	var accel = DE_ACCELERATION
	if dir.dot(hv) > 0:
		accel = ACCELERATION
	var new_pos = dir * max_speed
	
	if is_on_floor():
		hv = hv.linear_interpolate(new_pos, accel * delta)
	else:
		accel = AIR_DE_ACCELERATION
		if dir.dot(hv) > 0:
			accel = AIR_ACCELERATION
		new_pos = dir * max_speed
		hv = hv.linear_interpolate(new_pos, accel * delta)
	
	velocity.x = hv.x
	velocity.z = hv.z
	
	velocity = move_and_slide( velocity , Vector3.UP )
	
	if $CombatStats.health == 0:
		return
	
	if is_on_floor():
		_jumping = false
		_jump_count = MAX_JUMP
	
	if is_on_floor() or velocity.y > 0:
		_fall_time = 0.0
	else:
		_fall_time += delta
	
	if dir.length() > 0.1:
		var look_pos = global_transform.origin - dir
		var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
		global_transform = Transform(rotTransform.basis, global_transform.origin)
		global_transform.origin.z = 0
	
	if is_on_floor():
		if abs(velocity.x) > 0.5:
			_play_anim("Locomotion")
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
	
	if Input.is_action_just_pressed("use"):
		
		var usable = $UsableArea.get_usable()
		print("use: ", usable)
		if usable != null:
			usable.use(self)
	
	pass


func is_falling() -> bool:
	return _fall_time > 0.2


func take_object(object):
	
	print("Player take object")
	object.queue_free()


func _play_anim(name: String, force: bool = false):
	if _anim_update:
		return
	_anim_update = true
	$AnimationTree.travel(name)


func _on_WalkTimer_timeout():
	_walk_sound_ready = true


func _on_CombatStats_damage_taken():
	
	$AnimationTree.set("parameters/Hit/active", true)
	
	pass # Replace with function body.


func _on_CombatStats_health_depleted():
	
	$AnimationTree.set("parameters/Alive/current", 1)
	$Equipement/WeaponHandler.shoot_ready = false
	
	emit_signal("died")
	


func _on_CombatStats_health_changed(new_value, old_value):
	if new_value > 0:
		$AnimationTree.set("parameters/Alive/current", 0)
