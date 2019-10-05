extends ImmediateGeometry

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var weapon_pos := Vector3()
var target_pos := Vector3()

var laser_position := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_as_toplevel( true )
	
	global_transform.origin = Vector3()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	clear()
	
	
	begin(Mesh.PRIMITIVE_LINES)
	set_color(Color.red)
	add_vertex( weapon_pos )
	add_vertex( laser_position )
	
	"""
	begin(Mesh.PRIMITIVE_TRIANGLES)
	set_color(Color.red)
	add_vertex( Vector3(weapon_pos.x, weapon_pos.y, 0) )
	add_vertex( Vector3(target.x, target.y, 0) )
	add_vertex( Vector3(target.x, target.y+0.1, 0) )
	
	add_vertex( Vector3(weapon_pos.x, weapon_pos.y, 0) )
	add_vertex( Vector3(weapon_pos.x, weapon_pos.y+0.1, 0) )
	add_vertex( Vector3(target.x, target.y+0.1, 0) )
	"""
	end()
	
	
	pass


func _physics_process(delta):
	if visible:
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(weapon_pos, target_pos, [get_parent()], 0x03)
		if result != null and result.has("position"):
			laser_position = result["position"]
		else: 
			laser_position = target_pos
