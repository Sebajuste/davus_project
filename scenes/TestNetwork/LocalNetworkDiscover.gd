extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var port := 3333 setget _set_port

var _udp := PacketPeerUDP.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	_udp.listen(port)
	
	pass # Replace with function body.

func _exit_tree():
	_udp.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if _udp and _udp.get_available_packet_count() > 0:
		
		var packet := _udp.get_packet()
		var ip := _udp.get_packet_ip()
		var port := _udp.get_packet_port()
		
		var message = packet.get_string_from_utf8()
		
		print("message: ", message)
		
	
#	pass

func discover():
	
	
	
	pass

func _set_port(p):
	port = p
	_udp.close()
	_udp.listen(port)
