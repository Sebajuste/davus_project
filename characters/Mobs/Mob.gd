extends KinematicBody


var targets := []
var current_target = null
var ammo_type:String
var id_monster:int


# Called when the node enters the scene tree for the first time.
func _ready():
	$SpecialMonster.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_vulnerability(type: String):
	ammo_type = type
	#$SpecialMonster.visible = true


func face_to(position: Vector3):
	var look_pos := self.global_transform.origin
	look_pos.x = position.x
	var rotTransform = global_transform.looking_at(look_pos, Vector3.UP)
	global_transform = Transform(rotTransform.basis, global_transform.origin)


func move_to(position: Vector3):
	pass


func _on_Detection_body_entered(body):
	if body.is_in_group("player"):
		targets.append(body)


func _on_Detection_body_exited(body):
	var index = targets.find(body)
	if index >= 0:
		targets.remove(index)
