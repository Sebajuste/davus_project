extends Node


func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for i in save_nodes:
		var node_data = {
			"path": i.get_path(),
			"data": i.call("save")
		}
		save_game.store_line( to_json(node_data) )
	save_game.close()


func load_game() -> bool:
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return false# Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		var inventory = get_node( current_line["path"] )
		inventory.call("restore", current_line["data"])
	save_game.close()
	return true
