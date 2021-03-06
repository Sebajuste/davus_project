extends Node


export var max_power := 2.0
export var consumption := 1.0
export var reload := 0.5

export var max_speed := 5.0
export var acceleration := 1.0

var power := max_power

var jetpack_on := false

onready var _character = get_parent().get_parent()

var _start_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	if Input.is_action_pressed("jetpack"):
		_start_timer += delta
	elif not _character.is_falling():
		_start_timer = 0.0
	
	if Input.is_action_pressed("jetpack") and _start_timer > 0.5 and power > 0.0:
		power -= consumption * delta
		jetpack_on = true
	else:
		if power < max_power:
			power += reload * delta
		jetpack_on = false
	
	if power <= 0.0:
		jetpack_on = false


func _physics_process(delta):
	
	if jetpack_on:
		_character.velocity.y += acceleration
		if _character.velocity.y > max_speed:
			_character.velocity.y = max_speed
		_character._play_anim("Jetpack")
