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


#var _pistol_aiming := false


var _jump_event := false
var _jump_action := false
var _jump_count := MAX_JUMP
var _jumping := false

var _walk_sound_ready := true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#var valid_target := false
	
	
	_jump_event = false
	
	if $CombatStats.health == 0:
		return
	
	if Input.is_action_just_pressed("jump"):
		_jump_action = true
		_jump_event = true
	if Input.is_action_just_released("jump"):
		_jump_action =  false
	
	
	if $WeaponHandler.aiming and velocity.y < 0.1 and $WeaponHandler.valid_target:
		$WeaponHandler.shoot_ready = true
		$WeaponHandler.target = $CursorSelector.get_target_pos()
	else:
		$WeaponHandler.shoot_ready = false
	


func _physics_process(delta):
	
	var dir = Vector3()
	
	if $CombatStats.health > 0:
		if Input.is_action_pressed("move_right"):
			dir += Vector3.RIGHT
	
		if Input.is_action_pressed("move_left"):
			dir += Vector3.LEFT
	
	dir = dir.normalized()
	
	velocity.y += delta * -GRAVITY * 2
	
	
	
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
		if usable != null and usable.has_method("use"):
			usable.use(self)
	
	pass


func give_object(item) -> void:
	$Inventory.add_item(item)


func is_falling() -> bool:
	return _fall_time > 0.2


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
	$WeaponHandler.shoot_ready = false
	
	emit_signal("died")
	


func _on_CombatStats_health_changed(new_value, old_value):
	if new_value > 0:
		$AnimationTree.set("parameters/Alive/current", 0)


func _on_Inventory_item_equiped(item):
	
	print("Equip : ", item)
	
	print("items : ", $Inventory._items )
	
	pass # Replace with function body.
