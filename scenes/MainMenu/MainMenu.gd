extends Node

signal start_game

onready var _buttons := [
	$MainControls/MarginContainer/VBoxContainer/StartButton,
	$MainControls/MarginContainer/VBoxContainer/OptionsButton,
	$MainControls/MarginContainer/VBoxContainer/CreditsButton,
	$MainControls/MarginContainer/VBoxContainer/QuitButton,
]

var select_pos := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Spatial/FemaleCharacter/AnimationPlayer.play("angry")
	
	_buttons[select_pos].grab_focus()
	

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
	
	if Input.is_action_just_pressed("ui_accept") and not $Credits.visible:
		_buttons[select_pos].emit_signal("pressed")
	

func _on_StartButton_pressed():
	
	loading.change_scene("res://scenes/MainGame/MainGame.tscn")
	


func _on_OptionsButton_pressed():
	$MainControls.visible = false
	$Options.visible = true


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Options_on_close():
	$MainControls.visible = true
	$Options.visible = false


func _on_CreditsButton_pressed():
	
	$Credits.start()
	
