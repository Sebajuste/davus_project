extends StaticBody

const RAY_LENGTH = 1000

onready var camera = get_tree().get_root().get_camera() setget set_camera

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_as_toplevel(true)
	$Target.set_as_toplevel(true)
	


func _process(delta):
	if camera:
		var target_pos = _mouse_pos( get_viewport().get_mouse_position() )
		$Target.global_transform.origin = target_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if camera:
		var cam_pos = camera.get_global_transform().origin
		cam_pos.z = -0.5
		self.global_transform.origin = cam_pos
	


func set_camera(c: Camera):
	if c:
		camera = c


func get_target_pos() -> Vector3:
	return $Target.global_transform.origin

func _mouse_pos(mouse_pos) -> Vector3:
	
	# Get the 3D cursor position
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], 0x80)
	
	var target_pos = Vector3()
	
	if result:
		target_pos = result.position
		target_pos.z = 0
	
	return target_pos
