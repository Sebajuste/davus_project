extends Camera

export var target: NodePath
export(float, 1.0, 100.0) var distance := 10.0

export var speed := 10.0
export var target_y_offset := 5.0

onready var target_node = get_node(target)


var _target_posistion := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	_target_posistion = Vector3(
		target_node.global_transform.origin.x,
		target_node.global_transform.origin.y + target_y_offset,
		target_node.global_transform.origin.z + distance
	)
	
	if target_node.get("velocity"):
		var velocity = target_node.velocity
		if velocity.length() > 1.5:
			_target_posistion += velocity / 5
	

func _physics_process(delta):
	
	#var distance = (_target_posistion - self.global_transform.origin).length()
	self.global_transform.origin = self.global_transform.origin.linear_interpolate(_target_posistion, delta * speed)
	
	pass
