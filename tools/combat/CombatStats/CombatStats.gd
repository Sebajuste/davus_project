extends Node

class_name CombatStats

signal health_changed(new_value, old_value)
signal health_depleted()
signal damage_taken()

export var max_health: int = 1 setget set_max_health

export var fire_resistance: int = 0 setget set_fire_resistance
export var ice_resistance: int = 0 setget set_ice_resistance

var health: int

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	health = max_health


func take_damage(hit: Hit) -> void:
	if health == 0:
		return
	var old_health = health
	
	var damage : int
	match hit.type:
		"Fire":
			damage = hit.damage - fire_resistance
		"Ice":
			damage = hit.damage - ice_resistance
		_:
			damage = hit.damage
	
	health -= damage
	emit_signal("damage_taken")
	health = max(0, health)
	emit_signal("health_changed", health, old_health)
	if health == 0:
		emit_signal("health_depleted")


func heal(amount: int) -> void:
	var old_health = health
	health = min(health + amount, max_health)
	if old_health != health:
		emit_signal("health_changed", health, old_health)


func set_max_health(value: int) -> void:
	if value == null:
		return
	max_health = max(1, value)


func set_fire_resistance(value: int) -> void:
	if value == null:
		return
	fire_resistance = max(0, value)


func set_ice_resistance(value: int) -> void:
	if value == null:
		return
	ice_resistance = max(0, value)
