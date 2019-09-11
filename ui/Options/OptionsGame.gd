extends VBoxContainer

onready var language_select = $HBoxContainer/languageList


const LANGUAGES = {
	"en": "English",
	"fr": "Français"
}


var language


func reload():
	
	language = configuration.Settings.Game.Language
	
	var language_text = LANGUAGES[language]
	
	for index in language_select.get_item_count():
		var text = language_select.get_item_text(index)
		if text == language_text:
			language_select.select(index)

func apply():
	
	configuration.Settings.Game.Language = language
	

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for key in LANGUAGES:
		language_select.add_item( LANGUAGES[key] )
	
	reload()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_languageList_item_selected(ID):
	
	var language_selected = language_select.get_item_text(ID)
	
	for key in LANGUAGES:
		if LANGUAGES[key] == language_selected:
			language = key
			return
	
