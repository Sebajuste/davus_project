extends Control

signal closed

export(String, MULTILINE) var message := "" setget set_message

# Called when the node enters the scene tree for the first time.
func _ready():
	
	modal_message.connect("message_opened", self, "set_message")
	
	$MarginContainer/VBoxContainer/Footer/MarginContainer/HBoxContainer/CloseButton.grab_focus()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_message(content):
	if content != null:
		message = content
		$MarginContainer/VBoxContainer/Body/MarginContainer/RichTextLabel.text = content
		$MarginContainer/VBoxContainer/Footer/MarginContainer/HBoxContainer/CloseButton.grab_focus()
		visible = true


func _on_CloseButton_pressed():
	visible = false
	emit_signal("closed")
	
