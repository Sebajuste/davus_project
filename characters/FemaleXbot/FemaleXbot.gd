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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	_anim_update = false
	
	
	
	
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
			pass
	
	
	if Input.is_action_just_pressed("jump") and _fall_time < 0.25 and _jump_counter > 0:
		_jump_counter -= 1
		
		if abs(velocity.x) > 0.1:
			_play_anim("jump_run_in_place")
			velocity += Vector3.UP * 10
		else:
			_jumping = true
			_jumping_timer = 0.0
			_play_anim("JumpIdle")
	
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
	
	
	#var state_machines = $AnimationTree["parameters/playback"]
	
	if is_falling():
		_play_anim("Falling")
	#elif abs(velocity.x) > 2:
	#	_play_anim("Locomotion")
	#	set("parameters/Locomotion/blend_position", velocity.x / max_speed)
	elif abs(velocity.x) > 0.5:
		$AnimationTree.set("parameters/Locomotion/blend_position", abs(velocity.x) / max_speed)
		_play_anim("Locomotion")
	else:
		_play_anim("idle")


func is_falling() -> bool:
	return not is_on_floor() and velocity.y < -0.05


func _play_anim(name: String):
	if _anim_update:
		return
	_anim_update = true
	
	$AnimationTree.travel(name)
	
	"""
	var state_machines = $AnimationTree["parameters/playback"]
	if state_machines.is_playing():
		state_machines.travel(name)
	else:
		state_machines.start(name)
	"""
