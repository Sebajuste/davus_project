class_name WeaponResource

# Ammo
const AMMO_TYPES:Array = [ 
		"Fire", 
		"Ice", 
	]

# Weapons
enum eWeaponsType { Pistol, SMG } # AssaultRifle,
const WEAPONS_NAME:Dictionary = {
	eWeaponsType.Pistol : "pistol",
	eWeaponsType.SMG : "smg",
	#eWeaponsType.AssaultRifle : "rifle",
}

const WEAPONS_SETTINGS:Dictionary = {
	eWeaponsType.Pistol: {
		"Damage": {
			"Min": 8,
			"Max": 15,
		},
		"Rate": {
			"Min": 120,
			"Max": 150,
		},
	},
	eWeaponsType.SMG: {
		"Damage": {
			"Min": 10,
			"Max": 15,
		},
		"Rate": {
			"Min": 300,
			"Max": 350,
		},
	},
}
"""
eWeaponsType.AssaultRifle: {
	"Damage": {
		"Min": 20,
		"Max": 30,
	},
	"Rate": {
		"Min": 60,
		"Max": 70,
	},
},

"""