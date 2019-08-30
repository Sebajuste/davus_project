extends Spatial

const LevelBatch = preload("LevelBatch.tscn")

export var world_seed := 1
export var batch_size := 16



var noise := OpenSimplexNoise.new()

var _current_batch_x := 99999
var _current_batch_y := 99999

var _thread := Thread.new()
var _stop_tread := false
var _stop_thread_mutex := Mutex.new()

var _add_batch_queue := []
var _add_batch_mutex := Mutex.new()

var _batch_loc_queue := []
var _batchloc_queue_mutex := Mutex.new()

func _ready():
	
	noise.seed = world_seed
	noise.octaves = 3
	noise.period = 3.0
	noise.persistence = 0
	noise.lacunarity = 1
	
	_thread.start(self, "_load_thread")
	

func _process(delta):
	
	_add_batch_mutex.lock()
	
	while not _add_batch_queue.empty():
		var batch = _add_batch_queue.pop_front()
		add_child(batch)
	_add_batch_mutex.unlock()
	

func _exit_tree():
	_stop_thread_mutex.lock()
	_stop_tread = true
	_stop_thread_mutex.unlock()
	_thread.wait_to_finish()
	pass


func update(global_x: float, global_y: float):
	
	var x = int(global_x / (batch_size * 2))
	if global_x < 0:
		x -= 1
	
	var y = int(global_y / (batch_size * 2))
	if global_y < 0:
		y -= 1
	
	var update_gen := false
	
	if x != _current_batch_x or y != _current_batch_y:
		_current_batch_x = x
		_current_batch_y = y
		update_gen = true
	
	if update_gen:
		update_gen = false
		
		# Gen position required
		var batches_required := []
		for i in range(-1, 2):
			for j in range(-1, 2):
				batches_required.append(Vector3(x+(i-0), y+(j), 0))
		
		# Search existing nodes, and remove them from the require list
		# Remove also unecessaries batches
		for batch in get_children():
			var batch_pos = _to_batch_loc(batch.global_transform.origin)
			var index = batches_required.find(batch_pos)
			if index != -1:
				batches_required.remove(index)
			else:
				
				remove_child(batch)
				batch.free()
			#	batch.queue_free()
		
		# generate missing batches
		_batchloc_queue_mutex.lock()
		for batch_loc in batches_required:
			_batch_loc_queue.push_back(batch_loc)
		_batchloc_queue_mutex.unlock()




func _to_batch_loc(global_pos: Vector3) -> Vector3:
	return Vector3(global_pos.x / (batch_size*2), global_pos.y / (batch_size*2), global_pos.z / (batch_size*2))




func _load_thread(data):
	
	while true:
		var next_loc = null
		_batchloc_queue_mutex.lock()
		if not _batch_loc_queue.empty():
			next_loc = _batch_loc_queue.pop_front()
		_batchloc_queue_mutex.unlock()
		
		if next_loc != null:
			_load_batch(next_loc)
		
		_stop_thread_mutex.lock()
		if _stop_tread:
			_stop_thread_mutex.unlock()
			return
		_stop_thread_mutex.unlock()
		
	

func _load_batch(loc: Vector3):
	
	var level_batch = load("res://tools/LevelBatch.tscn").instance()
	
	level_batch._noise = noise
	
	level_batch.translate( Vector3(loc.x*batch_size*2, loc.y*batch_size*2, 0) )
	level_batch.gen( Vector3(loc.x*batch_size, loc.y*batch_size, 0) )
	
	_add_batch_mutex.lock()
	_add_batch_queue.push_back(level_batch)
	_add_batch_mutex.unlock()
	
