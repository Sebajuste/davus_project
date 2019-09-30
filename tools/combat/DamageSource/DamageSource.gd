extends Area

class_name DamageSource

signal hit(target)

export var damage: int = 1
export var reactivation_timer := 0.0 setget set_reactivation_timer
export(String, "Normal", "Fire", "Ice") var type := "Normal"


func set_reactivation_timer(value):
	reactivation_timer = value
	$ReactivationTimer.wait_time = max(0, reactivation_timer)


func _on_DamageSource_hit(target):
	if reactivation_timer > 0.0:
		$CollisionShape.disabled = true
		$ReactivationTimer.start()


func _on_ReactivationTimer_timeout():
	
	$CollisionShape.disabled = false
	
