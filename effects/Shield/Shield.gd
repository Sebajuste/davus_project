extends MeshInstance

export var color := Color(0, 1, 0.952941) setget set_color
export var power := 2.0 setget set_power
export var intensity := 2.0 setget set_intensity

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_surface_material(0, get_surface_material(0).duplicate())
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_color(value: Color):
	color = value
	self.get_surface_material(0).set_shader_param("Color", value )

func set_power(value: float):
	power = value
	self.get_surface_material(0).set_shader_param("Power", value )

func set_intensity(value: float):
	intensity = value
	self.get_surface_material(0).set_shader_param("Intensity", value )
