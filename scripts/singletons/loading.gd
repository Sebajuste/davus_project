extends Node

const LOADING = preload("res://ui/Loading/Loading.tscn")

var current_scene = null

var _loading_ui

var _loader : ResourceInteractiveLoader
var _poll_index: int


# Called when the node enters the scene tree for the first time.
func _ready():
	_loading_ui = LOADING.instance()
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _loader != null:
		var result = _loader.poll()
		_poll_index += 1
		_loading_ui.set_progress(0, _loader.get_stage_count(), _poll_index)
		if result == ERR_FILE_EOF:
			var s = _loader.get_resource()
			_loader = null
			_poll_index = 0
			current_scene = s.instance()
			get_tree().get_root().remove_child( _loading_ui )
			get_tree().get_root().add_child( current_scene )
			get_tree().set_current_scene( current_scene )


func change_scene(path: String):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	current_scene.free()
	_loader = ResourceLoader.load_interactive(path)
	_poll_index = 0
	get_tree().get_root().add_child( _loading_ui )
	get_tree().set_current_scene( _loading_ui )
	_loading_ui.set_progress(0, 100, 0)
