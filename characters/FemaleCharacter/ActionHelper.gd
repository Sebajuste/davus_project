extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	var pos = global_transform.origin
	var cam = get_tree().get_root().get_camera()
	var screen_pos = cam.unproject_position(pos)
	
	$Control.set_position( Vector2(screen_pos.x - $Control.rect_size.x/2, screen_pos.y - $Control.rect_size.y/2) )
	
	$Control/Keyboard.visible = controller.type == Controller.Type.MOUSE_KEYBOARD
	$Control/Gamepad.visible = controller.type == Controller.Type.GAMEPAD




func _on_ActionHelper_visibility_changed():
	
	$Control.visible = visible
	
	pass # Replace with function body.
