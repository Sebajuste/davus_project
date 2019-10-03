extends Node

const Pistol = preload("res://objects/weapons/Pistol/Pistol.tscn")
const SMG = preload("res://objects/weapons/SMG/SMG.tscn")
const AssaultRifle = preload("res://objects/weapons/AssaultRifle/AssaultRifle.tscn")

signal aimed(state)

export var right_hand: NodePath
export var inventory: NodePath
export var ammo_handler: NodePath
export var shield_handler: NodePath
export var auto_equip := true

var aiming := false setget set_aiming
var shoot_ready := true
var target: Vector3
var current_item = null
var weapon = null
var weapon_item : Item
var valid_target := false

onready var _right_hand_node: Node = get_node(right_hand)
onready var _inventory_node: Node = get_node(inventory)
onready var _ammo_node: Node = get_node(ammo_handler)
onready var _shield_handler_node: Node = get_node(shield_handler)

var _weapon_available_list := []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	_inventory_node.connect("item_added", self, "_on_add_weapon")
	_inventory_node.connect("item_removed", self, "_on_remove_weapon")
	_inventory_node.connect("item_updated", self, "_on_update_weapon")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if aiming:
		aiming_pistol()
	else:
		valid_target = false
	
	if _shield_handler_node and _shield_handler_node.is_enable():
		valid_target = false
	
	if Input.is_action_pressed("shoot") and shoot_ready and valid_target:
		if weapon:
			var ammo = null
			if _ammo_node:
				ammo = _ammo_node.get_ammo()
			if weapon.shoot(target, ammo):
				if controller.type == Controller.Type.GAMEPAD:
					match weapon_item.properties["type"]:
						"pistol":
							Input.start_joy_vibration (0, 0.5, 0.0, 0.1)
						"smg":
							Input.start_joy_vibration (0, 0.25, 0.0, 0.1)
						"rifle":
							Input.start_joy_vibration (0, 0.75, 0.0, 0.1)


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
	weapon_item = item
	if item.properties.has("type"):
		match item.properties["type"]:
			"pistol":
				weapon = Pistol.instance()
			"smg":
				weapon = SMG.instance()
			"rifle":
				weapon = AssaultRifle.instance()
	else:
		weapon = Pistol.instance()
	weapon.firing_rate = item.properties["rate"]
	_right_hand_node.add_child(weapon)
	item.equiped = true
	_update_anim()


func aiming_pistol():
	
	var bone = $"../Skeleton".find_bone("mixamorig_Spine2")
	
	var bone_pos = $"../Skeleton".get_bone_global_pose(bone).origin
	
	var cur_dir = get_parent().global_transform.basis.z.normalized()
	var target_pos = target - (get_parent().global_transform.origin+bone_pos)
	var target_dir = target_pos.normalized()
	
	var look_dot = cur_dir.dot(target_dir)
	
	if look_dot > 0.2:
		
		valid_target = target_pos.length() > 2.0
		
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
	_update_anim()
	emit_signal("aimed", aiming)


func _update_anim():
	if aiming:
		var weapon_type = 1
		if weapon_item != null and weapon_item.properties.has("type") and weapon_item.properties["type"] != "pistol":
			weapon_type = 2
		$"../AnimationTree".set("parameters/StateMachine/Idle/Weapon/current", weapon_type)
		$"../AnimationTree".set("parameters/StateMachine/Locomotion/Weapon/current", weapon_type)
		$"../AnimationTree".set("parameters/StateMachine/Locomotion/WeaponBackward/current", weapon_type)
	else:
		$"../AnimationTree".set("parameters/StateMachine/Idle/Weapon/current", 0)
		$"../AnimationTree".set("parameters/StateMachine/Locomotion/Weapon/current", 0)
		$"../AnimationTree".set("parameters/StateMachine/Locomotion/WeaponBackward/current", 0)



func _on_add_weapon(item: Item) -> void:
	if item.type == "gun" and _weapon_available_list.find(item) == -1:
		_weapon_available_list.append(item)
		if auto_equip and _weapon_available_list.size() == 1:
			equip_weapon(item)


func _on_remove_weapon(item: Item) -> void:
	var index = _weapon_available_list.find(item)
	if index != -1:
		_weapon_available_list.remove(index)


func _on_update_weapon(item: Item) -> void:
	if _weapon_available_list.find(item) != -1:
		if item.equiped:
			equip_weapon(item)
