extends VBoxContainer


var aiming := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	controller.connect("controller_changed", self, "_on_controller_changed")
	
	_on_controller_changed(controller.type)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_controller_changed(controller_type):
	$MoveKeyboard.visible = false
	$JumpKeyboard.visible = false
	$UnsheatheKeyboard.visible = false
	$UseKeyboard.visible = false
	$ShootKeyboard.visible = false
	$ShieldKeyboard.visible = false
	
	$MoveGamepad.visible = false
	$JumpGamepad.visible = false
	$UnsheatheGamepad.visible = false
	$UseGamepad.visible = false
	$ShootGamepad.visible = false
	$ShieldGamepad.visible = false
	
	match controller_type:
		Controller.Type.MOUSE_KEYBOARD:
			$MoveKeyboard.visible = true
			$JumpKeyboard.visible = true
			if not aiming:
				$UnsheatheKeyboard.visible = true
			else:
				$ShootKeyboard.visible = true
			$UseKeyboard.visible = true
			$ShieldKeyboard.visible = true
		Controller.Type.GAMEPAD:
			$MoveGamepad.visible = true
			$JumpGamepad.visible = true
			if not aiming:
				$UnsheatheGamepad.visible = true
			else:
				$ShootGamepad.visible = true
			$UseGamepad.visible = true
			$ShieldGamepad.visible = true


func _on_WeaponHandler_aimed(state):
	aiming = state
	_on_controller_changed(controller.type)
