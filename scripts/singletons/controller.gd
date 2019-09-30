extends Node

class_name Controller

enum Type { MOUSE_KEYBOARD, GAMEPAD }

signal controller_changed(controller_type)

var type = Type.MOUSE_KEYBOARD


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	var event_controller = null
	if event is InputEventMouse:
		event_controller = Type.MOUSE_KEYBOARD
	if event is InputEventKey:
		event_controller = Type.MOUSE_KEYBOARD
	if event is InputEventJoypadMotion:
		event_controller = Type.GAMEPAD
	if event is InputEventJoypadButton:
		event_controller = Type.GAMEPAD
	
	if event_controller != null and event_controller != type:
		type = event_controller
		emit_signal("controller_changed", event_controller)
