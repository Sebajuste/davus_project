extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if not visible:
		return
	
	if Input.is_action_just_pressed("ui_page_down"):
		var next_tab = $MarginContainer/TabContainer.current_tab + 1
		if next_tab >= $MarginContainer/TabContainer.get_child_count():
			next_tab = 0
		$MarginContainer/TabContainer.current_tab = next_tab
	
	if Input.is_action_just_pressed("ui_page_up"):
		var previous_tab = $MarginContainer/TabContainer.current_tab - 1
		if previous_tab < 0:
			previous_tab = $MarginContainer/TabContainer.get_child_count() - 1
		$MarginContainer/TabContainer.current_tab = previous_tab
	


func _on_Menu_visibility_changed():
	var tabs = $MarginContainer/TabContainer
	
	for panel in tabs.get_children():
		if panel.get_child_count() > 0:
			var child = panel.get_child(0)
			if not panel.get_child(0).get("active") == null:
				panel.get_child(0).active = false
	
	if visible:
		var current_tab = tabs.current_tab
		if tabs.get_child(current_tab).get_child_count() > 0:
			var child = tabs.get_child(current_tab).get_child(0)
			if child.get("active") != null:
				child.set("active", true)
	
	pass # Replace with function body.
