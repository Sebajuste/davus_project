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
		"hash_file": buffer.sha256_text()
	}
	save_game.store_line( to_json(security) )
	save_game.close()


func load_game() -> bool:
	var save_game = File.new()
	if not save_game.file_exists("user://davus.save"):
		return false
	var hash_readed: String
	var buffer := ""
	var data_list := []
	save_game.open("user://davus.save", File.READ)
	while not save_game.eof_reached():
		var json = save_game.get_line()
		var node_data = parse_json(json)
		if node_data == null:
			pass
		elif node_data.get("hash_file") != null:
			hash_readed = node_data.get("hash_file")
		else:
			buffer += json
			data_list.append( node_data )
	if data_list.empty():
		return false
	buffer += SALT
	var hash_calculated = buffer.sha256_text()
	save_game.close()
	if not hash_readed or hash_calculated != hash_readed:
		return false
	for node_data in data_list:
		var item = get_node( node_data["path"] )
		item.call("restore", node_data["data"])
	return true
