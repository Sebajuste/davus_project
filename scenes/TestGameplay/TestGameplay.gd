extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _reset_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
		
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if _reset_timer > 0.0:
		_reset_timer -= delta
		_reset_timer = max(0.0, _reset_timer)
		if _reset_timer == 0.0:
			$Player.global_transform.origin = Vector3(0, 1.1, 0)
			$Player/CombatStats.heal( $Player/CombatStats.max_health )
	
	pass


func _on_Player_died():
	
	_reset_timer = 5.0
	
