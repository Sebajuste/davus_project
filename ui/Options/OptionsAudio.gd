extends VBoxContainer


onready var general_slider = $Master/Slider
onready var music_slider = $Music/Slider
onready var effects_slider = $SoundEffects/Slider
onready var mute_checkbox = $Mute/Checkbox

var general := 100
var music := 100
var sound_effects := 100
var mute := false

func reload():
	
	general = configuration.Settings.Audio.MASTER
	music = configuration.Settings.Audio.MUSIC
	sound_effects = configuration.Settings.Audio.SOUND_EFFECTS
	
	mute = configuration.Settings.Audio.MUTE
	
	
	general_slider.value = ( (general + 20) * 100) / 25
	music_slider.value = ( (music + 20) * 100) / 25
	effects_slider.value = ( (sound_effects + 20) * 100) / 25
	
	mute_checkbox.pressed = mute
	
	pass


func apply():
	
	configuration.Settings.Audio.MASTER = general
	configuration.Settings.Audio.MUSIC = music
	configuration.Settings.Audio.SOUND_EFFECTS = sound_effects
	
	configuration.Settings.Audio.MUTE = mute
	


# Called when the node enters the scene tree for the first time.
func _ready():
	
	reload()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_General_value_changed(value):
	
	general = ( (value * 25) / 100 ) - 20
	

func _on_Music_value_changed(value):
	
	music = ( (value * 25) / 100 ) - 20
	

func _on_Effects_value_changed(value):
	
	sound_effects = ( (value * 25) / 100 ) - 20
	

func _on_Mute_toggled(button_pressed):
	
	mute = button_pressed
	
