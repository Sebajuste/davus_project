extends Node

signal start_game

onready var _buttons := [
	$Control/MarginContainer/VBoxContainer/StartButton,
	$Control/MarginContainer/VBoxContainer/QuitButton,
]

var select_pos := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_up"):
		select_pos -= 1
		if select_pos < 0:
			select_pos = _buttons.size() - 1
		_buttons[select_pos].grab_focus()
	
	if Input.is_action_just_pressed("ui_down"):
		select_pos += 1
		if select_pos >= _buttons.size():
			select_pos = 0
		_buttons[select_pos].grab_focus()
	
	if Input.is_action_just_pressed("ui_accept"):
		_buttons[select_pos].emit_signal("pressed") 
	

func _on_StartButton_pressed():
	
	get_tree().change_scene("res://scenes/TestWorldGameplay/TestWorldGameplay.tscn")
	


func _on_QuitButton_pressed():
	get_tree().quit()
