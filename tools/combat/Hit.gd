class_name Hit

var damage: = 0
var type := "Normal"

func _init(source: DamageSource) -> void:
	damage = source.damage
	type = source.type
