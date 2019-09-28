extends Node

signal notification_created(title, message, options)
signal notification_pushed(notification, options)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func create_notification(title: String, message: String, options: Dictionary = {}):
	
	emit_signal("new_notification", title, message, options)
	


func push_notification(notification: Control, options: Dictionary = {}) -> void:
	
	emit_signal("notification_pushed", notification, options)
	
