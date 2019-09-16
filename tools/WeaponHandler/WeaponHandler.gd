extends Node

const Pistol = preload("res://objects/weapons/Pistol/Pistol.tscn")

export var right_hand: NodePath


onready var _right_hand_node: Node = get_node(right_hand)

var shoot_ready := true

var target: Vector3

var _weapon_ref = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var weapon = Pistol.instance()
	_right_hand_node.add_child(weapon)
	_weapon_ref = weakref( weapon )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _weapon_ref and Input.is_action_pressed("shoot") and shoot_ready:
		var weapon = _weapon_ref.get_ref()
		if weapon:
			weapon.shoot(target)


func remove():
	for child in _right_hand_node.get_children():
		child.queue_free()
	_weapon_ref = null
