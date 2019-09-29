extends Node


var _control_camera := true

func _enter_tree():
	_start_init_level( $World/Level/Dungeon )

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Menu.visible = false
	
	_end_init_level( $World/Level/Dungeon )
	
	$Menu/MarginContainer/TabContainer/Options/Options.enable_savegame = true
	
	#
	# Add default Weapon
	#
	var default_weapon := Item.new()
	default_weapon.type = "gun"
	default_weapon.properties["damage"] = 10
	default_weapon.properties["rate"] = 60
	
	$World/Player.give_item(default_weapon)
	#$World/Player/Inventory.equip(default_weapon)
	
	#
	# Add default ammo
	# 
	var default_ammo := Item.new()
	default_ammo.type = "ammo"
	default_ammo.properties["ammo_type"] = "normal"
	
	$World/Player.give_item(default_ammo)
	
	
	
	pass # Replace with function body.


func _exit_tree():
	save.save_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	
	if Input.is_action_just_pressed("menu"):
		$Menu.visible = !$Menu.visible
	
	if Input.is_action_just_pressed("inventory"):
		if not $Menu.visible:
			$Menu.visible = true
			$Menu/MarginContainer/TabContainer.current_tab = 1
			pass
		elif $Menu/MarginContainer/TabContainer.current_tab != 1:
			$Menu/MarginContainer/TabContainer.current_tab = 1
		else:
			$Menu.visible = false
	
	if Input.is_action_just_pressed("map"):
		if not $Menu.visible:
			$Menu.visible = true
			$Menu/MarginContainer/TabContainer.current_tab = 2
			pass
		elif $Menu/MarginContainer/TabContainer.current_tab != 2:
			$Menu/MarginContainer/TabContainer.current_tab = 2
		else:
			$Menu.visible = false
	
	if event is InputEventKey and not event.is_pressed():
		if event.scancode == KEY_9:
			_select_camera()
		if event.scancode == KEY_8:
			$World/Level/Dungeon.create_dungeon()


func set_map(map):
	
	$Menu/MarginContainer/TabContainer/Map.add_child(map)
	


func _select_camera():
	$World/CameraPlayer.current = not _control_camera
	$World/CameraMap.current = _control_camera
	_control_camera = not _control_camera


func _start_init_level(scene: Node, context: Dictionary = {}):
	scene.player = $World/Player
	scene.camera = $World/Camera
	scene.context = context


func _end_init_level(scene: Node, context: Dictionary = {}):
	for map in $Menu/MarginContainer/TabContainer/Map.get_children():
		map.queue_free()
	var map = scene.find_node("Map")
	if map:
		scene.remove_child(map)
		$Menu/MarginContainer/TabContainer/Map.add_child(map)


func _on_Player_died():
	
	var level = $World/Level.get_child(0)
	
	if level:
		level.reset_player($World/player)
	
	pass # Replace with function body.
