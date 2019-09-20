extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Player.global_transform.origin = Vector3(0, 30, 0)
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	$StreamingLevel._load_queued_batch()
	$StreamingLevel._process(0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
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
		
	
	
	$StreamingLevel.update($Camera.global_transform.origin.x, $Camera.global_transform.origin.y)
	


func _on_PlayerRespawnTimer_timeout():
	
	$Player.global_transform.origin = Vector3(0, 30, 0)
	$Player/CombatStats.heal( $Player/CombatStats.max_health )
	


func _on_FemaleCharacter_died():
	
	$PlayerRespawnTimer.start()
	
