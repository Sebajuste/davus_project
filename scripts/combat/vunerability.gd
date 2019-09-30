class_name Vunerability



func add_vulnerability(type: String, stats: CombatStats):
	
	match type:
		"Fire":
			stats.armor = 20
			stats.fire_resistance = 0
			stats.ice_resistance = 20
			pass
		"Ice":
			stats.armor = 20
			stats.fire_resistance = 20
			stats.ice_resistance = 0
			pass