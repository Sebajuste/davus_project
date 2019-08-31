extends KinematicBody


const GRAVITY := 9.8

export var speed := 10

const ACCELERATION = 3
const DE_ACCELERATION = 7




var velocity := Vector3()

var _fall_time := 0.0
var _jump_counter := 1

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
	
	if Input.is_action_just_pressed("jump") and _fall_time < 0.25 and _jump_counter > 0:
		_jump_counter -= 1
		velocity += Vector3.UP * 10
		_play_anim("jump")
	
	
	var hv = velocity
	hv.y = 0
	
	var accel = DE_ACCELERATION
	if dir.dot(hv) > 0:
		accel = ACCELERATION
	
	var new_pos = dir * speed
	
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
	
	if not is_on_floor() and velocity.y < -0.05:
		_play_anim("falling_cycle")
	elif abs(velocity.x) > 2:
		_play_anim("slow_run")
	elif abs(velocity.x) > 0.5:
		_play_anim("walk")
	else:
		_play_anim("idle")

func _play_anim(name: String):
	if _anim_update:
		return
	_anim_update = true
	var state_machines = $AnimationTree["parameters/playback"]
	if state_machines.is_playing():
		state_machines.travel(name)
	else:
		state_machines.start(name)
