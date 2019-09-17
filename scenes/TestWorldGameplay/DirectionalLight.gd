extends DirectionalLight

onready var camera = get_tree().get_root().get_camera()

export var max_y := 0
export var min_y := -20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not camera:
		return
	
	var weight = (clamp(camera.global_transform.origin.y, min_y, max_y) + (max_y-min_y) ) / (max_y-min_y)
	
	light_energy = lerp(0, 2, weight)
	
