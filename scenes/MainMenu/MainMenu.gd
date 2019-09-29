extends Node

signal start_game


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Spatial/FemaleCharacter/AnimationPlayer.play("angry")
	$MainControls/MarginContainer/VBoxContainer/StartButton.grab_focus()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	
	loading.change_scene("res://scenes/MainGame/MainGame.tscn")
	


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
