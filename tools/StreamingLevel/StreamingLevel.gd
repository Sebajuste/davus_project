extends Spatial

signal batch_added(batch)
signal batch_removed(batch)

export(int) var batch_size := 16
export var multithreading := true

var _current_batch_x := 99999
var _current_batch_y := 99999

var _thread := Thread.new()
var _stop_tread := false
var _stop_thread_mutex := Mutex.new()

var _add_batch_queue := []
var _add_batch_mutex := Mutex.new()

var _batch_loc_queue := []
var _batchloc_queue_mutex := Mutex.new()


class DeleteItem:
	var batch
	var timer

var _delete_queue := []
var _delete_queue_mutex := Mutex.new()

var _layouts := []

var _current_batch_loc := []

func _ready():
	if multithreading:
		_thread.start(self, "_thread_process")
	for child in get_children():
		if child != $Batches:
			_layouts.append(child)
			child.batch_size = batch_size


func _process(delta):
	_add_batch_mutex.lock()
	while not _add_batch_queue.empty():
		var batch = _add_batch_queue.pop_front()
		if batch:
			$Batches.add_child(batch)
			emit_signal("batch_added", batch)
	_add_batch_mutex.unlock()
	
	var index := 0
	for item in _delete_queue:
		item.timer += delta
		if item.timer > 5.0:
			call_deferred("_delete_batch", item.batch)
			_delete_queue.remove(index)
			return
		index += 1
	
	if not multithreading:
		_load_queued_batch()
	
	"""
	_delete_queue_mutex.lock()
	while not _delete_queue.empty():
		var batch = _delete_queue.pop_front()
		batch.queue_free()
	_delete_queue_mutex.unlock()
	"""


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
		var batches_loc_required := []
		for i in range(-1, 2):
			for j in range(-1, 2):
				batches_loc_required.append(Vector3(x+(i-0), y+(j), 0))
		
		var batch_loc_delete_list := []
		
		for batch_loc in _current_batch_loc:
			var index = batches_loc_required.find(batch_loc)
			if index == -1:
				batch_loc_delete_list.append(batch_loc)
			else:
				batches_loc_required.remove(index)
		
		
		_batchloc_queue_mutex.lock()
		for batch_loc in batches_loc_required:
			_current_batch_loc.append(batch_loc)
			_batch_loc_queue.push_back(batch_loc)
		_batchloc_queue_mutex.unlock()
		
		
		for delete_loc in batch_loc_delete_list:
			var index =_current_batch_loc.find(delete_loc)
			if index >= 0:
				_current_batch_loc.remove(index)
			for batch in $Batches.get_children():
				var batch_loc = _to_batch_loc(batch.global_transform.origin)
				if batch_loc.x == delete_loc.x && batch_loc.y == delete_loc.y:
					emit_signal("batch_removed", batch)
					$Batches.remove_child(batch)
					_delete_queue_mutex.lock()
					
					var delete_item = DeleteItem.new()
					delete_item.batch = batch
					delete_item.timer = 0.0
					_delete_queue.push_back(delete_item)
					_delete_queue_mutex.unlock()


func _to_batch_loc(global_pos: Vector3) -> Vector3:
	return Vector3(global_pos.x / (batch_size*2), global_pos.y / (batch_size*2), global_pos.z / (batch_size*2))


func _thread_process(data):
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


func _load_queued_batch():
	var next_loc = null
	_batchloc_queue_mutex.lock()
	if not _batch_loc_queue.empty():
		next_loc = _batch_loc_queue.pop_front()
	_batchloc_queue_mutex.unlock()
	if next_loc != null:
		_load_batch(next_loc)


func _load_batch(loc: Vector3):
	for layout in _layouts:
		var layout_batch = layout.gen(Vector3(loc.x, loc.y, 0))
		if layout_batch:
			_add_batch_mutex.lock()
			_add_batch_queue.push_back(layout_batch)
			_add_batch_mutex.unlock()


func _delete_batch(batch):
	batch.free()
	pass
