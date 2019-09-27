extends Node

const Pistol = preload("res://objects/weapons/Pistol/Pistol.tscn")

export var right_hand: NodePath

export var ammo: NodePath

onready var _right_hand_node: Node = get_node(right_hand)
onready var _ammo_node: Node = get_node(ammo)

var aiming := false setget set_aiming

var shoot_ready := true

var target: Vector3

var current_item = null
var weapon = null

var valid_target := false

# Called when the node enters the scene tree for the first time.
func _ready():

	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("shoot") and shoot_ready:
		if weapon:
			var ammo = null
			if _ammo_node:
				ammo = _ammo_node.get_ammo()
			weapon.shoot(target, ammo)
	
	if aiming:
		aiming_pistol()
	else:
		valid_target = false


func _input(event):
	if Input.is_action_just_pressed("unsheathe"):
		set_aiming(not aiming)


func remove():
	if weapon:
		if current_item:
			current_item.equiped = false
		weapon.queue_free()
	weapon = null
	current_item = false
	set_aiming( false )


func equip_weapon(item: Item):
	remove()
	weapon = Pistol.instance()
	weapon.firing_rate = item.properties["rate"]
	_right_hand_node.add_child(weapon)
	item.equiped = true


func aiming_pistol():
	
	var target_pos = $"../CursorSelector".get_target_pos()
	
	var bone = $"../Skeleton".find_bone("mixamorig_Spine2")
	
	var bone_pos = $"../Skeleton".get_bone_global_pose(bone).origin
	
	var cur_dir = get_parent().global_transform.basis.z.normalized()
	var target_dir = (target_pos - (get_parent().global_transform.origin+bone_pos)).normalized()
	
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
		
		var rest: Transform = $"../Skeleton".get_bone_pose(bone)
		var new_pose = rest.rotated(Vector3.RIGHT, rotation_angle)
		
		$"../Skeleton".set_bone_pose( bone, new_pose )
	else:
		valid_target = false


func set_aiming(value):
	if weapon == null:
		return
	aiming = value
	if aiming:
		$"../AnimationTree".set("parameters/StateMachine/Idle/Weapon/current", 1)
		$"../AnimationTree".set("parameters/StateMachine/Locomotion/Weapon/current", 1)
	else:
		$"../AnimationTree".set("parameters/StateMachine/Idle/Weapon/current", 0)
		$"../AnimationTree".set("parameters/StateMachine/Locomotion/Weapon/current", 0)
