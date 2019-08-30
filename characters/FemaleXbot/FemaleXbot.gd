extends KinematicBody


const GRAVITY := 9.8

export var speed := 10

const ACCELERATION = 3
const DE_ACCELERATION = 7




var velocity := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	
	var dir = Vector3()
	
	if Input.is_action_pressed("move_right"):
		dir += Vector3.RIGHT
	
	if Input.is_action_pressed("move_left"):
		dir += Vector3.LEFT
	
	dir = dir.normalized()
	
	velocity.y += delta * -GRAVITY * 2
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity += Vector3.UP * 10
	
	
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
	
	if dir != Vector3():
		var look_pos = global_transform.origin - dir
		var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
		global_transform = Transform(rotTransform.basis, global_transform.origin)
		global_transform.origin.z = 0
	
	
	var state_machines = $AnimationTree["parameters/playback"]
	
	# print("velocity: ", velocity)
	
	if velocity.length() > 2:
		if state_machines.is_playing():
			state_machines.travel("slow_run")
		else:
			state_machines.start("slow_run")
	elif velocity.length() > 0.5:
		if state_machines.is_playing():
			state_machines.travel("walk")
		else:
			state_machines.start("walk")
	else:
		if state_machines.is_playing():
			state_machines.travel("idle")
		else:
			state_machines.start("idle")
	