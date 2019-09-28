extends MeshInstance


signal shield_changed(power, max_power)


export var max_power = 10 setget set_max_power
export var reload_timer := 1.0 setget set_reload_timer
export var reload_value := 1

var power = max_power setget set_power


export var _shader_param_power := 2.0 setget _set_shader_param_power

# Called when the node enters the scene tree for the first time.
func _ready():
	
	disable()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func is_enable() -> bool:
	return visible


func enable():
	if $CombatStats.health > 0:
		visible = true
		$HitBox/CollisionShape.disabled = false
		$ReloadTimer.stop()


func disable():
	visible = false
	$HitBox/CollisionShape.disabled = true
	$ReloadTimer.start()


func set_max_power(value):
	max_power = max(0, value)
	$CombatStats.max_health = max_power


func set_reload_timer(value):
	
	reload_timer = value
	


func set_power(value):
	power = clamp(value, 0, max_power)
	$CombatStats.health = power
	emit_signal("shield_changed", power, max_power)
	self.get_surface_material(0).set_shader_param("Intensity", power/float(max_power) )


func _set_shader_param_power(value: float):
	_shader_param_power = value
	self.get_surface_material(0).set_shader_param("Power", value )


func _on_CombatStats_health_changed(new_value, old_value):
	power = new_value
	emit_signal("shield_changed", power, max_power)
	self.get_surface_material(0).set_shader_param("Intensity", power/float(max_power) )


func _on_ReloadTimer_timeout():
	
	set_power(power + reload_value)
	


func _on_CombatStats_damage_taken():
	
	$AnimationPlayer.play("hit")
	
