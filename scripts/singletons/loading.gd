extends Node

signal scene_loading
signal scene_loaded(scene)
signal scene_load_progress(current_stage, stage_count)

const LOADING = preload("res://ui/Loading/Loading.tscn")

var current_scene = null

var _loading_ui

var _loader : ResourceInteractiveLoader
var _poll_index: int

var _loading := false
var _switch_scene := false
var _loading_context: Dictionary

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
			var resource = _loader.get_resource()
			_loader = null
			_poll_index = 0
			_loading = false
			var scene = resource.instance()
			emit_signal("scene_loaded", scene, _loading_context)
			if _switch_scene:
				current_scene = scene
				get_tree().get_root().remove_child( _loading_ui )
				get_tree().get_root().add_child( current_scene )
				get_tree().set_current_scene( current_scene )


func change_scene(path: String, context: Dictionary = {}):
	if not _loading:
		_loading = true
		_switch_scene = true
		_loading_context = context
		emit_signal("scene_loading")
		call_deferred("_deferred_load_scene", path)


func load_scene(path: String, context: Dictionary = {}):
	if not _loading:
		_loading = true
		_switch_scene = false
		_loading_context = context
		emit_signal("scene_loading")
		call_deferred("_deferred_load_scene", path)


func _deferred_load_scene(path):
	_poll_index = 0
	_loader = ResourceLoader.load_interactive(path)
	if _switch_scene:
		current_scene.free()
		get_tree().get_root().add_child( _loading_ui )
		get_tree().set_current_scene( _loading_ui )
		_loading_ui.set_progress(0, 100, 0)
