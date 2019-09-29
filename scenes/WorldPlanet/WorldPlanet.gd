extends Spatial

var player setget set_player

var camera: Camera

var context: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$StreamingLevel.update(camera.global_transform.origin.x, camera.global_transform.origin.y)
	$StreamingLevel._load_queued_batch()
	$StreamingLevel._process(0)
	
	if context and context.has("player_position"):
		var pos: Vector3 = context["player_position"]
		player.global_transform.origin = pos
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	$StreamingLevel.update(camera.global_transform.origin.x, camera.global_transform.origin.y)
	


func set_player(p):
	
	player = p
	


func init_scene():
	player.global_transform.origin = Vector3(0, 30, 0)
	player.reset()
	


func reset_player(player: Spatial) -> void:
	
	$PlayerRespawnTimer.start()
	
