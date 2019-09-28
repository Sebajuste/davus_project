extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$StartTimer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartTimer_timeout():
	
	loading.change_scene("res://scenes/MainMenu/MainMenu.tscn")
	
