extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func control(delta):
	
	var player: Node2D = get_parent()
	
	player._dir = Vector2()
	
	if Input.is_action_pressed("move_right"):
		player._dir += Vector2.RIGHT
	if Input.is_action_pressed("move_left"):
		player._dir += Vector2.LEFT
	if Input.is_action_pressed("move_up"):
		player._dir += Vector2.UP
	if Input.is_action_pressed("move_down"):
		player._dir += Vector2.DOWN
	player._dir = player._dir.normalized()
	
