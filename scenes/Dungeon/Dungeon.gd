extends Spatial

# Minimap Parameters
export var scale2D:int = 10

# Dungeon Generator Parameters
export var player_lifes:int = 3
export var room_margin:int = 2
export (int, 2, 10) var number_of_rooms:int = 12
export var min_nb_key:int = 2
export (float, 0, 0.75) var key_occupation = 0.6
export var map_width:int = 80
export var map_height:int = 50
export var min_room_width:int = 9
export var max_room_width:int = 9
export var min_room_height:int = 5
export var max_room_height:int = 5
export (float, 0, 1) var mob_chance_corridors:float = 0.5
export (float, 0, 1) var mob_chance_rooms:float = 0.5
export (float, 0, 1) var chance_monster_or_door:float = 1
export (float, 0, 1) var chance_drop_rack:float = 0.25
export (float, 0, 1) var chance_drop_datapad:float = 0.25

export var map_seed = 1



# Constants
const TILE_SIZE = 2
const DRAW_ROOMS_INDEX = false

var player setget set_player
var camera: Camera

var context: Dictionary 

var _control_camera:bool = true
var _rnd := RandomNumberGenerator.new()
var _graph_generator := GraphGenerator.new()
var _remaining_lifes:int
var _map

func _ready():
	
	if context and context.has("dungeon_seed"):
		map_seed = context["dungeon_seed"]
	
	_remaining_lifes = player_lifes
	
	_rnd.seed = map_seed
	
	# Initiate graph generator
	_graph_generator.rnd = _rnd
	_graph_generator.room_margin = room_margin
	_graph_generator.number_of_rooms = number_of_rooms	
	_graph_generator.map_width = map_width
	_graph_generator.map_height = map_height
	_graph_generator.min_room_width = min_room_width
	_graph_generator.max_room_width = max_room_width
	_graph_generator.min_room_height = min_room_height
	_graph_generator.max_room_height = max_room_height
	_graph_generator.map_seed = map_seed
	
	# Initiate map generator
	var dg := $MapGenerator
	dg.tile_size = TILE_SIZE
	dg.min_nb_key = min_nb_key
	dg.key_occupation = key_occupation
	dg.mob_chance_corridors = mob_chance_corridors
	dg.mob_chance_rooms = mob_chance_rooms
	dg.chance_monster_or_door = chance_monster_or_door
	dg.chance_drop_rack = chance_drop_rack
	dg.chance_drop_datapad = chance_drop_datapad
	dg.rnd = _rnd
	
	# Initiate Mini map
	$Map/Viewport/MiniMap.scale2D = scale2D
	$Map/Viewport/MiniMap.draw_room_index = DRAW_ROOMS_INDEX
	$Map/Viewport/MiniMap.graph_generator = _graph_generator
	
	_map = $Map/Viewport/MiniMap
	
	while not create_dungeon():
		pass


func set_player(p):
	player = p



func reset_player(pPlayer: Spatial) -> void:
	$PlayerRespawnTimer.start()
	
func _on_PlayerRespawnTimer_timeout():
	_remaining_lifes -= 1
	if _remaining_lifes > 0:
		player.global_transform.origin = $MapGenerator.spawn_position
		var combat_stats = player.find_node("CombatStats")
		combat_stats.heal( combat_stats.max_health )
	else:
		loading.load_scene("res://scenes/WorldPlanet/WorldPlanet.tscn")

func create_dungeon() -> bool:
	var mg := $MapGenerator
	_graph_generator.clear_all()
	mg.clear_all()
	_graph_generator.gen_graph()
	if not mg.gen_dungeon(_graph_generator):
		return false
	_map.graph_generator = _graph_generator
	return true

func refresh_map():
	if player and _map:
		_map.gen(player.global_transform.origin / TILE_SIZE)

func _on_MapGenerator_dungeon_gen_finished(graph_generator):
	if player:
		player.global_transform.origin = $MapGenerator.spawn_position
		refresh_map()


func _on_MapGenerator_request_new_dungeon():
	return create_dungeon()