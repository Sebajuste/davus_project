extends Node

class_name CombatStats

signal health_changed(old_value, new_value)
signal health_depleted()
signal damage_taken()

export var max_health: int = 1 setget set_max_health
export var attack: int = 1

var health: int

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	health = max_health


func take_damage(hit: Hit) -> void:
	var old_health = health
	health -= hit.damage
	emit_signal("damage_taken")
	health = max(0, health)
	print("health: ", health)
	emit_signal("health_changed", health, old_health)
	if health == 0:
		emit_signal("health_depleted")


func heal(amount: int) -> void:
	var old_health = health
	health = min(health + amount, max_health)
	emit_signal("health_changed", health, old_health)


func set_max_health(value: int) -> void:
	if value == null:
		return
	max_health = max(1, value)

