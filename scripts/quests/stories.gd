class_name Stories


const STORIES := [
	"story_01",
	"story_02",
	"story_03",
	"story_04",
	"story_05",
	"story_06",
	"story_07",
	"story_08",
	"story_09",
	"story_10"
]


var _stories := []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _init():
	
	reset()
	
	pass # Replace with function body.

func reset():
	_stories.clear()
	for story in STORIES:
		_stories.append(story)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_random_story() -> String:
	if _stories.empty():
		reset()
	var index = randi() % _stories.size()
	var story = tr(_stories[index])
	_stories.remove(index)
	return story
