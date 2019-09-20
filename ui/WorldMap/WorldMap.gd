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
	print("streaming_level_node: ", streaming_level_node)
	streaming_level_node.connect("batch_added", self, "_on_batch_added")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_batch_added(batch) -> void:
	print("batch_added")
	if batch.is_in_group("body_streaming_layout"):
		for tile in batch.get_children():
			var tile_pos = tile.global_transform.origin
			if tile_pos.y <= 30.0:
				$Viewport/CanvasLayer._tiles_positions.append( Vector2(tile_pos.x, -tile_pos.y) )
		$Viewport/CanvasLayer.update()
