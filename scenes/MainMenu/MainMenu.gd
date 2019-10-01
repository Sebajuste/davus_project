extends Node

signal start_game



var _cinematic_started := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Spatial/FemaleCharacter/AnimationPlayer.play("angry")
	$MainControls/MarginContainer/VBoxContainer/StartButton.grab_focus()
	
	set_alarm(false)
	set_console(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if _cinematic_started and ( Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel") ):
		start_game()
	



func set_alarm(value: bool):
	var mat = $Spatial/SpaceShip/ShipInterior/Gyro/GyroClass.mesh.surface_get_material(0)
	mat.emission_enabled = value
	$Spatial/AlarmLight.visible = value
	if value:
		$AlarmAnimationPlayer.play("alarm")
	else:
		$AlarmAnimationPlayer.stop()


func set_console(value: bool):
	var mat = $Spatial/Console/Datapad.get_surface_material(1)
	mat.emission_enabled = value
	


func start_game():
	
	loading.change_scene("res://scenes/MainGame/MainGame.tscn")
	



func _on_StartButton_pressed():
	_cinematic_started = true
	$MainControls.visible = false
	$CinematicAnimationPlayer.play("intro")


func _on_OptionsButton_pressed():
	$MainControls.visible = false
	$Options.visible = true
	$Options/MarginContainer/Options.active = true


func _on_QuitButton_pressed():
	
	get_tree().quit()
	


func _on_CreditsButton_pressed():
	
	$Credits.start()
	


func _on_Options_closed():
	$MainControls.visible = true
	$Options.visible = false
	$Options/MarginContainer/Options.active = false
	$MainControls/MarginContainer/VBoxContainer/OptionsButton.grab_focus()
