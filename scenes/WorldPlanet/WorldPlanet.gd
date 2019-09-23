extends Spatial

var player setget set_player

var camera: Camera

var context: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	$StreamingLevel.update(camera.global_transform.origin.x, camera.global_transform.origin.y)
	$StreamingLevel._load_queued_batch()
	$StreamingLevel._process(0)
	
	
	if context and context.has("player_position"):
		var pos: Vector3 = context["player_position"]
		player.global_transform.origin = pos
	
	




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
	
	
	$StreamingLevel.update(camera.global_transform.origin.x, camera.global_transform.origin.y)
	


func set_player(p):
	player = p
	player.global_transform.origin = Vector3(0, 30, 0)
	#$Camera.target_node = player


func _on_PlayerRespawnTimer_timeout():
	
	player.global_transform.origin = Vector3(0, 30, 0)
	
	var combat_stats = player.find_node("CombatStats")
	combat_stats.heal( combat_stats.max_health )
	


func reset_player():
	
	$PlayerRespawnTimer.start()
	
