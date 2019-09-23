extends Node

const SALT = "gsSG28ZKeWEmgiuAdjvdfCK%By6e@n4CIzwuHMtW6YMn97&cQD5-)K7cbiD&n3nH"

func save_game():
	var save_game = File.new()
	save_game.open("user://davus.save", File.WRITE)
	var buffer := ""
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for item in save_nodes:
		var node_data = {
			"path": item.get_path(),
			"data": item.call("save")
		}
		var json = to_json(node_data)
		buffer += json
		save_game.store_line( json )
	buffer += SALT
	var security = {
		"hash": buffer.sha256_text()
	}
	save_game.store_line( to_json(security) )
	save_game.close()


func load_game() -> bool:
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return false
	var security: Dictionary
	var buffer := ""
	var data_list := []
	save_game.open("user://davus.save", File.READ)
	while not save_game.eof_reached():
		var json = save_game.get_line()
		var node_data = parse_json(json)
		if node_data["hash"]:
			security = node_data
		else:
			buffer += json
			data_list.append( node_data )
	buffer += SALT
	var hash_calculated = buffer.sha256_text()
	save_game.close()
	if not security or hash_calculated != security["hash"]:
		return false
	for node_data in data_list:
		var item = get_node( node_data["path"] )
		item.call("restore", node_data["data"])
	return true
