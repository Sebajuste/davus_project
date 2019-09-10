extends Node

# Temps de refresh de position par le réseau
const UPDATE_INTERVAL := 0.500

# Temp depuis le dernier reresh
var _current_time := 0.0 

var _last_pos := Vector2() # Dernière position reçue
var _extrap_pos := Vector2() # Position extrapolée

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	_current_time += delta # met à jour le temps
	
	# Si on est maitre, on envois notre position + la velocité aux autres joueurs
	if is_network_master() and _current_time > UPDATE_INTERVAL:
		rpc_unreliable("_set_status", get_parent().position, get_parent().velocity)
		_current_time = 0.0

#
# N'est appelé que pour interpoler la position reçue par réseau
#
func control(delta):
	
	var lerptime = _current_time / UPDATE_INTERVAL # valeur de l'interpolation de 0.0 à 1.0
	
	# on interpole de la dernière position (à la reception du packet) à la prochaine déduite
	var next_pos = _last_pos.linear_interpolate(_extrap_pos, lerptime)
	
	#get_parent()._dir = (next_pos - get_parent().position).normalized()
	get_parent().position = next_pos # - get_parent()._dir * get_parent().velocity
	
	pass

#
# Est appelé à chaque fois qu'un packet avec la position et la velocité est reçue
#
remote func _set_status(pos: Vector2, velocity: Vector2):
	
	#var jitter = _current_time - UPDATE_INTERVAL # TODO : pour la compensation du lag
	
	# on extrapole la prochaine position qui doit arriver dans UPDATE_INTERVAL millisecondes
	_extrap_pos = pos + velocity * UPDATE_INTERVAL
	
	# On sauvegarde la position actuelle pour l'interpolation de position
	_last_pos = get_parent().position
	
	_current_time = 0.0 # remise à 0 du compteur de temps
