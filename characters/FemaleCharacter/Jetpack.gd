extends Node


export var max_power := 1.0
export var consumption := 1.0
export var reload := 0.5

export var max_speed := 5.0
export var acceleration := 1.0

export(float, 0.1, 1.0) var activation_delay := 0.3

var power := max_power

var jetpack_on := false

onready var _character = get_parent().get_parent()

var _start_jetpack := false

var _start_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	if not _character:
		return
	
	if (_character._jumping or _character.is_falling() ) and _character._jump_event:
		_start_jetpack = true
	
	if _character.is_on_floor():
		_start_jetpack = false
		_start_timer = 0.0
	
	if _start_jetpack:
		_start_timer += delta
	#elif not _character.is_falling():
	#	_start_timer = 0.0
	
	if Input.is_action_pressed("jetpack") and _start_timer > activation_delay and power > 0.0:
		power -= consumption * delta
		power = max(0.0, power)
		jetpack_on = true
		_character._jumping = false
		if not $AudioStreamPlayer3D.playing and power > 0.1:
			$AudioStreamPlayer3D.play()
	else:
		if power < max_power:
			power += reload * delta
			power = min(power, max_power)
		jetpack_on = false
		$AudioStreamPlayer3D.stop()
	
	if power == 0.0:
		jetpack_on = false
		$AudioStreamPlayer3D.stop()


func _physics_process(delta):
	
	if _character and jetpack_on:
		_character.velocity.y += acceleration
		if _character.velocity.y > max_speed:
			_character.velocity.y = max_speed
		_character._play_anim("Jetpack")
