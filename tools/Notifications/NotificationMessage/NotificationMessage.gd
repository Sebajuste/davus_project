extends Panel


signal on_close


export var title := "" setget set_title
export var message := "" setget set_message
export var hide_close_button := false setget set_hide_close_button
export var auto_hide := true setget set_auto_hide
export var show_time := 10.0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = show_time
	if hide_close_button:
		$MarginContainer/VBoxContainer/CloseButton.visible = false
	if auto_hide:
		$MarginContainer/VBoxContainer/CloseButton.visible = false
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_title(value):
	title = value
	$MarginContainer/VBoxContainer/Label.text = title


func set_message(value):
	message = value
	$MarginContainer/VBoxContainer/RichTextLabel.text = value


func set_hide_close_button(value):
	hide_close_button = value
	$MarginContainer/VBoxContainer/CloseButton.visible = not hide_close_button


func set_auto_hide(value):
	auto_hide = value
	if auto_hide:
		$MarginContainer/VBoxContainer/CloseButton.visible = false
		$Timer.wait_time = show_time
		$Timer.start()


func close():
	
	emit_signal("on_close", self)
	
