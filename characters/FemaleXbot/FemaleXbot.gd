extends KinematicBody


const GRAVITY := 9.8

export var max_speed := 10

const ACCELERATION = 3
const DE_ACCELERATION = 7




var velocity := Vector3()

var _fall_time := 0.0
var _jump_counter := 1
var _jumping := false
var _jumping_timer := 0.0

var _anim_update := false


var _pistol_aiming := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if _pistol_aiming:
		
		var target_pos = $CursorSelector.get_target_pos()
		
		var bone = $Skeleton.find_bone("mixamorig_Spine2")
		
		var bone_pos = $Skeleton.get_bone_global_pose(bone).origin
		
		var cur_dir = global_transform.basis.z.normalized()
		var target_dir = (target_pos - (global_transform.origin+bone_pos)).normalized()
		
		var look_dir = Vector3()
		
		look_dir += Vector3.UP * Input.get_action_strength("look_up")
		
		#if Input.get_action_strength("look_down"):
		look_dir += Vector3.DOWN * Input.get_action_strength("look_down")
		
		#if Input.get_action_strength("look_right"):
		look_dir += Vector3.RIGHT * Input.get_action_strength("look_right")
		
		#if Input.get_action_strength("look_left"):
		look_dir += Vector3.LEFT * Input.get_action_strength("look_left")
		
		if look_dir.length() > 0.5:
			target_dir = look_dir.normalized()
		
		var look_dot = cur_dir.dot(target_dir)
		
		if look_dot > 0.2:
			
			var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)
			
			if (cur_dir + target_dir).x > 0 and (cur_dir + target_dir).y < 0:
				rotation_angle = -rotation_angle
			
			if (cur_dir + target_dir).x < 0 and (cur_dir + target_dir).y > 0:
				rotation_angle = -rotation_angle
			
			var rest: Transform = $Skeleton.get_bone_rest(bone)
			var new_pose = rest.rotated(Vector3.RIGHT, rotation_angle)
			
			$Skeleton.set_bone_pose( bone, new_pose )


func _physics_process(delta):
	
	var dir = Vector3()
	
	if Input.is_action_pressed("move_right"):
		dir += Vector3.RIGHT
	
	if Input.is_action_pressed("move_left"):
		dir += Vector3.LEFT
	
	dir = dir.normalized()
	
	velocity.y += delta * -GRAVITY * 2
	
	
	if _jumping:
		_jumping_timer += delta
		if _jumping_timer > 0.7:
			velocity += Vector3.UP * 10
			_jumping = false
	
	if Input.is_action_just_pressed("unsheathe"):
		_pistol_aiming = not _pistol_aiming
		
		if _pistol_aiming:
			$AnimationTree.set("parameters/StateMachine/Idle/Weapon/current", 1)
			$AnimationTree.set("parameters/StateMachine/Locomotion/Weapon/current", 1)
		else:
			$AnimationTree.set("parameters/StateMachine/Idle/Weapon/current", 0)
			$AnimationTree.set("parameters/StateMachine/Locomotion/Weapon/current", 0)
	
	if Input.is_action_just_pressed("jump") and _jump_counter > 0:
		if is_on_floor() or _fall_time < 0.25 or _fall_time > 0.5:
			_jump_counter -= 1
			_play_anim("jump_run_in_place", true)
			velocity.y = 10
	
	var hv = velocity
	hv.y = 0
	
	var accel = DE_ACCELERATION
	if dir.dot(hv) > 0:
		accel = ACCELERATION
	
	var new_pos = dir * max_speed
	
	hv = hv.linear_interpolate(new_pos, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z
	
	velocity = move_and_slide( velocity , Vector3.UP )
	
	if is_on_floor():
		_jump_counter = 1
		_fall_time = 0.0
	else:
		_fall_time += delta
	
	if dir != Vector3():
		var look_pos = global_transform.origin - dir
		var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
		global_transform = Transform(rotTransform.basis, global_transform.origin)
		global_transform.origin.z = 0
	
	
	if is_falling():
		_play_anim("Falling")
	elif abs(velocity.x) > 0.5:
		_play_anim("Locomotion")
	else:
		_play_anim("Idle")
	
	_anim_update = false


func is_falling() -> bool:
	return not is_on_floor() and (velocity.y < -0.05 or _fall_time > 0.5)


func _play_anim(name: String, force: bool = false):
	if _anim_update:
		return
	_anim_update = true
	$AnimationTree.travel(name)
