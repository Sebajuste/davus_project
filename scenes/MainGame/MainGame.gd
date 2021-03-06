extends Node


var _map_node


func _enter_tree():
	
	_start_init_level( $World/Level/WorldPlanet )
	


# Called when the node enters the scene tree for the first time.
func _ready():
	
	_map_node = $Menu/MarginContainer/TabContainer/Map
	
	$Menu.visible = false
	
	loading.connect("scene_loading", self, "_on_scene_loading")
	loading.connect("scene_load_progress", self, "_on_scene_load_progress")
	loading.connect("scene_loaded", self, "_on_scene_loaded")
	
	_end_init_level( $World/Level/WorldPlanet )
	
	$Menu/MarginContainer/TabContainer/Options/Options.enable_savegame = true
	
	var game_loaded = save.load_game()
	
	print("game_loaded: ", game_loaded)
	
	$Menu/MarginContainer/TabContainer/Options.name = tr("title_options")
	$Menu/MarginContainer/TabContainer/Inventory.name = tr("title_inventory")
	$Menu/MarginContainer/TabContainer/Map.name = tr("title_map")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if game_loaded:
		return
	
	#
	# Add default Weapon
	#
	var _weapon_resource = WeaponResource.new()
	var default_weapon := Item.new()
	default_weapon.type = "gun"
	var p = _weapon_resource.eWeaponsType.Pistol
	default_weapon.properties["type"] = _weapon_resource.WEAPONS_NAME[p]
	default_weapon.properties["damage"] = _weapon_resource.WEAPONS_SETTINGS[p]["Damage"]["Min"]
	default_weapon.properties["rate"] = _weapon_resource.WEAPONS_SETTINGS[p]["Rate"]["Min"]
	$World/Player.give_item(default_weapon, false)
	
	#
	# Add default ammo
	# 
	var default_ammo := Item.new()
	default_ammo.type = "ammo"
	default_ammo.properties["ammo_type"] = "normal"
	$World/Player.give_item(default_ammo, false)



func _exit_tree():
	save.save_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	
	if Input.is_action_just_pressed("menu"):
		$Menu.visible = !$Menu.visible
		_update_menu_state()
	
	if Input.is_action_just_pressed("inventory"):
		if not $Menu.visible:
			$Menu.visible = true
			$Menu/MarginContainer/TabContainer.current_tab = 1
		elif $Menu/MarginContainer/TabContainer.current_tab != 1:
			$Menu/MarginContainer/TabContainer.current_tab = 1
		else:
			$Menu.visible = false
		_update_menu_state()
	
	if Input.is_action_just_pressed("map"):
		if not $Menu.visible:
			$Menu.visible = true
			$Menu/MarginContainer/TabContainer.current_tab = 2
		elif $Menu/MarginContainer/TabContainer.current_tab != 2:
			$Menu/MarginContainer/TabContainer.current_tab = 2
		else:
			$Menu.visible = false
		_update_menu_state()
	
	
	


func set_map(map):
	
	_map_node.add_child(map)
	


func _update_menu_state():
	if $Menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		get_tree().paused = false



func _start_init_level(scene: Node, context: Dictionary = {}):
	scene.player = $World/Player
	scene.camera = $World/Camera
	scene.context = context


func _end_init_level(scene: Node, context: Dictionary = {}):
	for map in _map_node.get_children():
		map.queue_free()
	var map = scene.find_node("Map")
	if map:
		scene.remove_child(map)
		_map_node.add_child(map)
	
	if scene.has_method("init_scene"):
		scene.init_scene(context)


func _remove_level():
	for child in $World/Level.get_children():
		$World/Level.remove_child(child)


func _on_scene_loading():
	$Loading.visible = true
	pass


func _on_scene_loaded(scene, context: Dictionary):
	_remove_level()
	_start_init_level(scene, context)
	$World/Level.add_child(scene)
	_end_init_level(scene, context)
	if context.has("reset_player") and context["reset_player"] == true:
		$World/Player.reset()
	$Loading.visible = false


func _on_scene_load_progress(current_stage, stage_count):
	$Loading.set_progress(0, stage_count, current_stage)


func _on_Player_died():
	
	var level = $World/Level.get_child(0)
	
	if level and level.has_method("reset_player"):
		level.reset_player($World/Player)
	
	pass # Replace with function body.


func _on_DataPad_opened():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_Menu_closed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false


func _on_DataPad_closed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
