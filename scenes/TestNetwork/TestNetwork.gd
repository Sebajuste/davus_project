extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const Player = preload("Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	#$LobbiesDiscover.discover()
	
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CreateButton_pressed():
	
	$Connections.create_lobby(2345, 10)
	
	$Control.visible = false
	
	pass # Replace with function body.


func _on_JoinButton_pressed():
	
	$Connections.join_lobby("localhost", 2345)
	
	$Control.visible = false
	
	pass # Replace with function body.


func _on_Connections_connected():
	
	var selfPeerID = get_tree().get_network_unique_id()
	print("Create player ID ", selfPeerID)
	var player = Player.instance()
	player.set_name(str(selfPeerID))
	player.set_network_master(selfPeerID)
	player.control_handler = "Player"
	
	player.position = Vector2(randi() % 100 + 20, randi() % 100 + 20 )
	
	$World.add_child(player)
	
	pass # Replace with function body.



func _on_Connections_player_connected(id):
	print("Create player ID ", id)
	var player = Player.instance()
	player.set_name(str(id))
	player.set_network_master(id)
	player.control_handler = "Network"
	$World.add_child(player)
	


func _on_Connections_player_disconnected(id):
	
	var player = $World.find_node(str(id))
	if player:
		player.queue_free()
	
