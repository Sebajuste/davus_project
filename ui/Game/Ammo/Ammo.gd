extends Control

var ammo_selected: Item

# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon/Normal.visible = false
	$Icon/Fire.visible = false
	$Icon/Ice.visible = false
	$HelperKeyboard.visible = false
	$HelperGamepad.visible = false
	controller.connect("controller_changed", self, "_on_controller_changed")
	_on_controller_changed(controller.type)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ammo_selected(ammo: Item):
	$Icon/Normal.visible = false
	$Icon/Fire.visible = false
	$Icon/Ice.visible = false
	$HelperKeyboard.visible = false
	$HelperGamepad.visible = false
	ammo_selected = ammo
	if ammo == null:
		return
	match ammo.properties["ammo_type"]:
		"Normal":
			$Icon/Normal.visible = true
		"Fire":
			$Icon/Fire.visible = true
		"Ice":
			$Icon/Ice.visible = true
	
	_on_controller_changed(controller.type)


func _on_controller_changed(controller_type):
	$HelperKeyboard.visible = false
	$HelperGamepad.visible = false
	if ammo_selected == null:
		return
	match controller_type:
		Controller.Type.MOUSE_KEYBOARD:
			$HelperKeyboard.visible = true
		Controller.Type.GAMEPAD:
			$HelperGamepad.visible = true
