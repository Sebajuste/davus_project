extends Node

export var host := "localhost"
export(int, 3000, 65000 ) var port := 8080
export var game := "game_name"

export var lobby_name: String = "My Lobby"
export var max_player := 5

signal lobby_created

var _lobby_created := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_lobby(name):
	
	if _lobby_created:
		return
	
	_lobby_created = true
	
	lobby_name = name
	
	var lobby_information = {
		"name": lobby_name,
		"maxPlayer": max_player,
		"currentPlayer": 0,
		"host": "localhost",
		"port": 23456
	}
	
	var headers: PoolStringArray = ["Content-Type: application/json"]
	
	$CreateLobby.request("http://%s:%d/games-lobbies/games/%s/lobbies/%s" % [host, port, game, lobby_name], headers, true, HTTPClient.METHOD_PUT, JSON.print(lobby_information) )


func remove_lobby():
	
	$HTTPRequest.request("http://%s:%d/games-lobbies/games/%s/lobbies/%s" % [host, port, game, lobby_name], PoolStringArray(), true, HTTPClient.METHOD_DELETE)
	
	$PingTimer.stop()
	


func _on_CreateLobby_request_completed(result, response_code, headers, body):
	
	if result == 2:
		_lobby_created = false
		print("Cannot connect to the server")
		return
	
	$PingTimer.start()
	
	emit_signal("lobby_created")
	
	print("result: ", result, ", response_code: ", response_code, ", headers: ", headers, ", body: ", body.get_string_from_utf8() )


func _on_PingTimer_timeout():
	
	var lobby_information = {
		"name": lobby_name,
		"maxPlayer": max_player,
		"currentPlayer": 0,
		"host": "localhost",
		"port": 23456
	}
	
	var headers: PoolStringArray = ["Content-Type: application/json"]
	
	$CreateLobby.request("http://%s:%d/games-lobbies/games/%s/lobbies/%s" % [host, port, game, lobby_name], headers, true, HTTPClient.METHOD_PUT, JSON.print(lobby_information) )
	
