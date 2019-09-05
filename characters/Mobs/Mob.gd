extends KinematicBody


export var max_life := 100
export var attack := 20

var life: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	life = max_life
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func attack(target: Spatial):
	
	global_transform.looking_at(target.global_transform.origin, Vector3.UP)
	

func move_to(position: Vector3):
	pass
