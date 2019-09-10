extends Control

signal joined(host, port)

export var lobby_name := ""
export var current_player := 0
export var max_player := 4

export var host := ""
export var port := 23456

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$MarginContainer/HBoxContainer/Name.text = lobby_name
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JoinButton_pressed():
	
	emit_signal("joined", host, port)
	
