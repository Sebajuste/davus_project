extends Spatial

const Bullet = preload("../../projectiles/Bullet/Bullet.tscn")

export(float, 60, 1200) var firing_rate := 60.0 setget _set_firing_rate

var _fire_ready := true

var _shoot := false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$FireTimer.wait_time = firing_rate / 60
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _physics_process(delta):
	
	if _shoot:
		_shoot = false
		_shoot()
	
	pass


func shoot():
	_shoot = true


func _shoot():
	
	if _fire_ready:
		#print("shoot")
		_fire_ready = false
		$FireTimer.start()
		
		var bullet = Bullet.instance()
		
		var root_node = get_tree().get_root().get_child(0)
		root_node.add_child(bullet)
		
		bullet.direction = $Muzzle/FireDir.global_transform.origin - $Muzzle.global_transform.origin
		
		bullet.global_transform.origin = $Muzzle.global_transform.origin
		
		$ShootAudio.play()
		
	


func _set_firing_rate(fr):
	firing_rate = fr
	$FireTimer.wait_time = firing_rate / 60


func _on_FireTimer_timeout():
	_fire_ready = true
	pass # Replace with function body.
