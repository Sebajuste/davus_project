extends ViewportContainer

export var streaming_level: NodePath
export(float, 1.0, 10.0) var zoom := 2.0
export var walls_color := Color.white
export var player_color := Color.blue

#onready var streaming_level_node = get_node(streaming_level)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Viewport/CanvasLayer.zoom = zoom
	$Viewport/CanvasLayer.walls_color = walls_color
	$Viewport/CanvasLayer.player_color = player_color
	
	var streaming_level_node = get_node(streaming_level)
	streaming_level_node.connect("batch_added", self, "_on_batch_added")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_batch_added(batch) -> void:
	
	if batch.is_in_group("body_streaming_layout"):
		for tile in batch.get_children():
			var tile_pos = tile.global_transform.origin
			$Viewport/CanvasLayer._tiles_positions.append( Vector2(tile_pos.x, -tile_pos.y) )
		$Viewport/CanvasLayer.update()
	
	if batch.is_in_group("doors_streaming_layout"):
		for door in batch.get_children():
			var door_pos = door.global_transform.origin
			$Viewport/CanvasLayer._doors_positions.append( Vector2(door_pos.x, -door_pos.y) )
		$Viewport/CanvasLayer.update()
	
