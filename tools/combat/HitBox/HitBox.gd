extends Area

onready var collider: CollisionShape = $CollisionShape

export var combat_stats: NodePath

var is_active: = true setget set_is_active

var _damage_time := 0.0

onready var _combat_stats = get_node(combat_stats)


func _exit_tree():
	
	disconnect("area_entered", self, "_on_area_entered")
	


func _on_area_entered(damage_source: DamageSource) -> void:
	if get_parent().is_a_parent_of(damage_source):
		return
	var hit: = Hit.new(damage_source)
	if _combat_stats and _combat_stats.has_method("take_damage"):
		_combat_stats.take_damage(hit)
	damage_source.emit_signal("hit", self)
	_damage_time = 0.0


func set_is_active(value: bool) -> void:
	is_active = value
	collider.disabled = not value
