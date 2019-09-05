extends "res://characters/Mobs/Mob.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func attack(target: Spatial):
	.attack(target)

func move_to(position: Vector3):
	.move_to(position)
