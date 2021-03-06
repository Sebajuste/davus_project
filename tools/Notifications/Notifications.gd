extends CanvasLayer

var NotificationItem = preload("NotificationMessage/NotificationMessage.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	notifications.connect("notification_created", self, "create_notification")
	notifications.connect("notification_pushed", self, "push_notification")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func create_notification(title: String, message: String, options = {}) -> String:
	
	var notification = NotificationItem.instance()
	notification.title = title
	notification.message = message
	
	if options.has("hide_close_button"):
		notification.hide_close_button = options["hide_close_button"]
	if options.has("show_time"):
		notification.show_time = options["show_time"]
	if options.has("auto_hide"):
		notification.auto_hide = options["auto_hide"]
	
	notification.connect("closed", self, "_on_closed_notification")
	$MarginContainer/VBoxContainer.add_child(notification)
	
	return notification.get_name()


func push_notification(notification: Control, options: Dictionary) -> void:
	notification.connect("closed", self, "_on_closed_notification")
	$MarginContainer/VBoxContainer.add_child(notification)



func remove_notification(name: String) -> bool:
	
	var notification = $MarginContainer/VBoxContainer.get_node(name)
	
	if notification != null:
		notification.queue_free()
		return true
	return false


func clear():
	
	for notification in $MarginContainer/VBoxContainer.get_children():
		notification.queue_free()


func _on_closed_notification(notification):
	
	notification.queue_free()
	
