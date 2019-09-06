extends Node


signal connected
signal player_connected(id)
signal player_disconnected(id)

export var port := 23456

var player := {"username": ""} # Current player

var players := {} # List of all other players

var _enable := false


func _ready():
	
	# Subscribe at startup to all netweork connections events
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connect_succeeded")
	get_tree().connect("connection_failed", self, "_connect_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	print("Network service ready")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func is_enable():
	return _enable


#func is_master_server():
#	return _master_server


func create_lobby(port: int, max_player: int):
	var peer := NetworkedMultiplayerENet.new()
	var result = peer.create_server(port, max_player)
	if result == OK:
		get_tree().set_network_peer(peer)
		emit_signal("connected")
	#get_tree().set_meta("network_peer", peer)



func join_lobby(host, port):
	var peer := NetworkedMultiplayerENet.new()
	var result = peer.create_client(host, port)
	if result == OK:
		get_tree().set_network_peer(peer)
	#get_tree().set_meta("network_peer", peer)


func close():
	var peer = get_tree().get_network_peer()
	peer.close_connection()
	pass


func get_peers():
	return players.duplicate(true)


remote func _register_player(info):
	var id = get_tree().get_rpc_sender_id()
	print("New player join the game [ID=%d]" % id)
	"""
	 If i am the server, I must give the list of all other player
	if get_tree().is_network_server():
		rpc_id(id, "_register_player", 1, player) # send myself to new player
		for peer_id in players: # for all existing player
			rpc_id(id, "_register_player", peer_id, info) # send to new player the existant player
			rpc_id(peer_id, "_register_player", id, info) # send to the existant player the new player
	"""
	players[id] = info


func _player_connected(id):
	print("New Player connected [ID=%d]" % id)
	rpc_id(id, "_register_player", player)
	emit_signal("player_connected", id)
	pass


func _player_disconnected(id):
	print("A player was disconnected [ID=%d]" % id)
	players.erase(id)
	emit_signal("player_disconnected", id)
	pass


func _connect_succeeded():
	print("Connected to the server !")
	_enable = true
	emit_signal("connected")
	#rpc("_register_player", get_tree().get_network_unique_id(), player)
	pass


func _connect_fail():
	print("Cannot connect to the server")
	_enable = false
	pass


func _server_disconnected():
	print("Disconnected from server")
	_enable = false
	pass
