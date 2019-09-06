extends KinematicBody2D


export(String, "Player", "Network") var control_handler = "Player"

export var max_speed := 100.0
export var acceleration := 30.0

remote var velocity := Vector2()

var _dir := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _physics_process(delta):
	
	match control_handler:
		"Player":
			# Si c'est le noeud joueur, on vérifie les input avec le PlayerHandler
			$PlayerHandler.control(delta)
		"Network":
			# Si on ne controle pas le joueur, il faut executer l'interpolation de position
			$NetworkHandler.control(delta)
		_:
			pass
	
	# Calcul de la vitesse avec inertie
	var hv: Vector2 = velocity
	hv = hv.linear_interpolate(_dir * max_speed, delta * acceleration)
	velocity = self.move_and_slide(hv)
	
