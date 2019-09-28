extends Spatial



var _reset_timer := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var ui_inventory = $Menu/MarginContainer/TabContainer/Inventory/Inventory
	$Player/Inventory.connect("item_added", ui_inventory, "add_item")
	ui_inventory.connect("item_equiped", $Player/Inventory, "equip")
	
	var options = {
		"auto_hide": false
	}
	notifications.create_notification("Hello World", "This is a text message", options)
	
	$Menu.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if _reset_timer > 0.0:
		_reset_timer -= delta
		_reset_timer = max(0.0, _reset_timer)
		if _reset_timer == 0.0:
			$Player.global_transform.origin = Vector3(0, 1.1, 0)
			$Player/CombatStats.heal( $Player/CombatStats.max_health )
	
	pass


func _input(event):
	
	if Input.is_action_just_pressed("menu"):
		$Menu.visible = not $Menu.visible
	
	pass


func _on_Player_died():
	
	_reset_timer = 5.0
	
