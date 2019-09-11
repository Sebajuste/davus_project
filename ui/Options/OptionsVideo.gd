extends VBoxContainer

onready var resolution_select = $HBoxContainer/ResolutionList

onready var fullscreen_checkbox = $HBoxContainer2/Fullscreen
onready var vsync_checkbox = $HBoxContainer3/Vsync
onready var antialiasing_checkbox = $HBoxContainer4/Antialiasing


var display = {"h" : 0,"w":0}
var fullscreen
var antialiasing = true
var vsync = true


func reload():
	
	display.h = configuration.Settings.Display.HEIGHT
	display.w = configuration.Settings.Display.WIDTH
	fullscreen = configuration.Settings.Display.FullScreen
	vsync = configuration.Settings.Display.Vsync
	antialiasing = configuration.Settings.Display.Antialiasing
	
	for index in resolution_select.get_item_count():
		var text = resolution_select.get_item_text(index)
		var res = text.split("x")
		
		if res[1] == String(display.h) && res[0] == String(display.w):
			resolution_select.select(index)
	
	fullscreen_checkbox.pressed = fullscreen
	vsync_checkbox.pressed = vsync
	antialiasing_checkbox.pressed = antialiasing
	

func apply():
	
	print("apply video")
	
	configuration.Settings.Display.HEIGHT = display.h
	configuration.Settings.Display.WIDTH = display.w
	configuration.Settings.Display.FullScreen = fullscreen
	configuration.Settings.Display.Vsync = vsync
	configuration.Settings.Display.Antialiasing = antialiasing
	

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#resolution_select.add_item("640x480")
	resolution_select.add_item("800x600")
	resolution_select.add_item("1280x720")
	resolution_select.add_item("1600x900")
	resolution_select.add_item("1920x1080")
	
	reload()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ResolutionList_item_selected(ID):
	
	var res = resolution_select.get_item_text(ID).split("x")
	display.w = res[0]
	display.h = res[1]
	

func _on_Fullscreen_toggled(button_pressed):
	
	fullscreen = button_pressed
	

func _on_Vsync_toggled(button_pressed):
	
	vsync = button_pressed
	

func _on_Antialiasing_toggled(button_pressed):
	
	antialiasing = button_pressed
	
