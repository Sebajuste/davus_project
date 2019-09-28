class_name Item

var ID : int
var type : String
var equiped : bool = false
var properties := {}

func _init():
	pass


func save() -> Dictionary:
	return {
		"ID": ID,
		"type": type,
		"equiped": equiped,
		"properties": properties,
	}

func restore(data: Dictionary) -> void:
	ID = data.ID
	type = data.type
	equiped = data.equiped
	properties = data.properties
