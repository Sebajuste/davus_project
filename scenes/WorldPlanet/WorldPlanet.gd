extends Spatial

var player setget set_player

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#$Player.global_transform.origin = Vector3(0, 30, 0)
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	$StreamingLevel._load_queued_batch()
	$StreamingLevel._process(0)
	
	# TODO : send streaming level for world map
	
	# xxxx.streaming_level_node = $StreamingLevel
	
	var root = get_tree().get_root()
	
	#var map = $WorldMap
	#remove_child(map)
	
	#root.get_child(0).set_map(map)
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	"""
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("show_map"):
		if not $Menu.visible:
			$Menu.visible = true
			$Menu/MarginContainer/TabContainer.current_tab = 1
		elif $Menu/MarginContainer/TabContainer.current_tab != 1:
			$Menu/MarginContainer/TabContainer.current_tab = 1
		else:
			$Menu.visible = not $Menu.visible
	"""
	
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	


func set_player(p):
	player = p
	player.global_transform.origin = Vector3(0, 30, 0)
	$Camera.target_node = player


func _on_PlayerRespawnTimer_timeout():
	
	player.global_transform.origin = Vector3(0, 30, 0)
	
	var combat_stats = player.find_node("CombatStats")
	combat_stats.heal( combat_stats.max_health )
	


func reset_player():
	
	$PlayerRespawnTimer.start()
	
