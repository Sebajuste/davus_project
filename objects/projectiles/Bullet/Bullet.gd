extends Spatial

export var direction := Vector3() setget set_direction
export var speed := 20.0
export var life_time := 3.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	direction = direction.normalized()
	"""
	var look_pos = transform.origin + direction
	var rotTransform = transform.looking_at(look_pos, Vector3.UP)
	transform = Transform(rotTransform.basis, transform.origin)
	transform.origin.z = 0
	"""
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life_time -= delta
	if life_time <= 0:
		queue_free()


func _physics_process(delta):
	transform.origin = transform.origin + direction * speed * delta


func set_direction(dir):
	direction = dir.normalized()


func set_damage(damage: int) -> void:
	$DamageSource.damage = damage


func set_type(type: String) -> void:
	$DamageSource.type = type


func _destroy():
	queue_free()


func _on_Area_body_entered(body):
	call_deferred("_destroy")

