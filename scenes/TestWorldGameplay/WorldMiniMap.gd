extends Node2D


const TILE_SIZE = 2

export var streaming_level: NodePath
export(int, 1, 10) var zoom := 2

export var player_color := Color.blue

onready var streaming_level_node = get_node(streaming_level)


var _tiles_positions := []

var _update_timer := 0.0
var _player_origin = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	streaming_level_node.connect("batch_added", self, "_on_batch_added")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_timer += delta
	if _update_timer >= 0.20:
		_update_timer = 0.0
		update()
	
	pass


func _draw():
	
	var players = get_tree().get_nodes_in_group("player")
	
	var viewport_size: Vector2 = get_viewport().size
	
	var center_pos = Vector2(viewport_size.x/2, viewport_size.y/2)
	
	#var player_pos = players[0].global_transform.origin
	
	var player_origin = players[0].global_transform.origin
	
	if _player_origin == null:
		_player_origin = player_origin
	var player_pos = Vector2(player_origin.x, -player_origin.y) * zoom
	
	var origin_pos = center_pos - player_pos
	
	for tile_pos in _tiles_positions:
		var rect = Rect2(tile_pos.x*zoom+origin_pos.x, tile_pos.y*zoom+origin_pos.y, TILE_SIZE*zoom, TILE_SIZE*zoom)
		draw_rect( rect, Color.white, true)
	
	_draw_players(origin_pos)
	


func _draw_players(origin_pos: Vector2) -> void:
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		var player_pos = player.global_transform.origin
		var pos = Vector2(player_pos.x, -player_pos.y)
		#var rect = Rect2(pos.x*zoom+origin_pos.x, pos.y*zoom+origin_pos.y, TILE_SIZE*zoom, TILE_SIZE*zoom)
		#draw_rect( rect, player_color, true)
		draw_circle( Vector2(pos.x*zoom+origin_pos.x, pos.y*zoom+origin_pos.y), zoom, player_color)


func _on_batch_added(batch):
	if batch.is_in_group("body_streaming_layout"):
		for tile in batch.get_children():
			var tile_pos = tile.global_transform.origin
			if tile_pos.y <= 30.0:
				_tiles_positions.append( Vector2(tile_pos.x, -tile_pos.y) )
		
		update()



func _on_WorldMiniMap_visibility_changed():
	
	
	
	pass # Replace with function body.
