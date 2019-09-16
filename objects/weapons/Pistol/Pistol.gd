extends Spatial

const Bullet = preload("../../projectiles/Bullet/Bullet.tscn")

export(float, 60, 1200) var firing_rate := 60.0 setget _set_firing_rate

var _fire_ready := true

var _shoot := false
var _target_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$FireTimer.wait_time = firing_rate / 60
	



func _physics_process(delta):
	
	if _shoot:
		_shoot = false
		_shoot()
	
	pass


func shoot(target: Vector3):
	_shoot = true
	_target_pos = target


func _shoot():
	
	if _fire_ready:
		_fire_ready = false
		$FireTimer.start()
		
		var bullet = Bullet.instance()
		var root_node = get_tree().get_root().get_child(0)
		root_node.add_child(bullet)
		
		
		bullet.global_transform.origin = $Muzzle.global_transform.origin
		bullet.global_transform.origin.z = 0
		
		var dir = _target_pos - $Muzzle.global_transform.origin
		dir.z = 0
		
		bullet.direction = dir.normalized()
		
		
		$ShootAudio.play()
		
	


func _set_firing_rate(fr):
	firing_rate = fr
	$FireTimer.wait_time = firing_rate / 60


func _on_FireTimer_timeout():
	_fire_ready = true
	pass # Replace with function body.
