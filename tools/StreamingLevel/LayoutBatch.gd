extends Node

signal object_emited(object)

export var size := 16

# Must be override
func gen(loc: Vector3, noise: OpenSimplexNoise, cap: float) -> void:
	pass
