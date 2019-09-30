extends Camera

const VELOCITY_FACTOR := 5


export var target: NodePath
export(float, 1.0, 100.0) var distance := 10.0
export var speed := 10.0
export var max_offset := 3.0

onready var target_node = get_node(target)


var _target_posistion := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	_target_posistion = Vector3(
		target_node.global_transform.origin.x,
		target_node.global_transform.origin.y + 2,
		target_node.global_transform.origin.z + distance
	)
	
	if target_node.get("velocity"):
		var velocity = target_node.velocity
		if velocity.length() > 0.5:
			_target_posistion += velocity / VELOCITY_FACTOR
	
	if target_node.get("_look_dir"):
		if controller.type == Controller.Type.GAMEPAD:
			_target_posistion += target_node._look_dir
		elif abs(target_node._look_dir.x) > 12.0 or abs(target_node._look_dir.y) > 6.0:
			_target_posistion += target_node._look_dir
			pass
	
	_target_posistion.x = clamp(_target_posistion.x, target_node.global_transform.origin.x-max_offset, target_node.global_transform.origin.x+max_offset)
	_target_posistion.y = clamp(_target_posistion.y, target_node.global_transform.origin.y-max_offset, target_node.global_transform.origin.y+max_offset)
	_target_posistion.z = target_node.global_transform.origin.z + distance
	

func _physics_process(delta):
	
	self.global_transform.origin = self.global_transform.origin.linear_interpolate(_target_posistion, delta * speed)
	
