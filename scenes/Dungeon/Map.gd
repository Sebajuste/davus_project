extends ViewportContainer

export var map_generator: NodePath

var map_generator_node setget set_map_generator_node

# Called when the node enters the scene tree for the first time.
func _ready():
	
	map_generator_node = get_node(map_generator)
	
	if map_generator_node:
		map_generator_node.connect("dungeon_gen_finished", self, "_on_dungeon_gen_finished")
	


func update():
	$Viewport/MiniMap.update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_map_generator_node(v):
	if map_generator_node:
		map_generator_node.disconnect("dungeon_gen_finished", self, "_on_dungeon_gen_finished")
	map_generator_node = v
	map_generator_node.connect("dungeon_gen_finished", self, "_on_dungeon_gen_finished")


func _on_dungeon_gen_finished(graph_generator):
	
	$Viewport/MiniMap.graph_generator = graph_generator
	
