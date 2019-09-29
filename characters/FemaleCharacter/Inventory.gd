extends Node

signal item_added(item)
signal item_removed(item)
signal item_updated(item)


var items := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func equip(item):
	if item:
		item.equiped = true
		emit_signal("item_updated", item)


func get_items() -> Array:
	var all_items := []
	#for item in weapons:
	#	all_items.append(item)
	#for item in ammos:
	#	all_items.append(item)
	for item in items:
		all_items.append(item)
	return all_items


func add_item(item: Item):
	item.equiped = false
	items.append(item)
	
	emit_signal("item_added", item)


func remove_item(item: Item) -> bool:
	var index := items.find(item)
	if index != -1:
		items.remove(index)
		emit_signal("item_removed", item)
	return false


func save():
	var data = {
		"items": [],
	}
	for item in items:
		data.items.append( item.save() )
	return data


func restore( data ):
	items = []
	for item_data in data.items:
		var item = Item.new()
		item.restore(item_data)
		add_item( item )
