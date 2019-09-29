extends Spatial

export var direction := Vector3() setget set_direction
export var speed := 20.0
export var life_time := 3.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	direction = direction.normalized()
	


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
	print("bullet ", type)
	match type:
		"Fire":
			var mat = $Area/MeshInstance.material_override.duplicate()
			mat.albedo_color = Color.orange
			$OmniLight.light_color = Color.orange
			$Area/MeshInstance.material_override = mat
			$Area/MeshInstance.material_override = mat
			$Area/MeshInstance.material_override = mat
			pass
		"Ice":
			var mat = $Area/MeshInstance.material_override.duplicate()
			mat.albedo_color = Color.cyan
			$OmniLight.light_color = Color.cyan
			$Area/MeshInstance.material_override = mat
			$Area/MeshInstance.material_override = mat
			$Area/MeshInstance.material_override = mat
			pass
	
	


func _destroy():
	
	queue_free()
	

func _on_Area_body_entered(body):
	
	call_deferred("_destroy")
	

func _on_DamageSource_hit(target):
	
	queue_free()
	
