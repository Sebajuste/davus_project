extends Control


signal on_close


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func reload():
	for option in $Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer.get_children():
		if option.has_method("reload"):
			option.reload()


func _hide_all():
	var options = $Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer
	for option in options.get_children():
		option.visible = false


func _on_VideoOptions_pressed():
	_hide_all()
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsVideo.visible = true
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsVideo.reload()


func _on_AudioOptions_pressed():
	_hide_all()
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsAudio.visible = true
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsAudio.reload()


func _on_GameOptions_pressed():
	_hide_all()
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsGame.visible = true
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsGame.reload()


func _on_CancelButton_pressed():
	configuration.load_settings()
	configuration.apply_settings()


func _on_ApplyButton_pressed():
	for option in $Panel/MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer.get_children():
		if option.has_method("apply"):
			option.apply()
	configuration.apply_settings()


func _on_ApplySaveButton_pressed():
	_on_ApplyButton_pressed()
	configuration.save_settings()


func _on_ReturnButton_pressed():
	
	emit_signal("on_close")
	
