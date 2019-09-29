class_name WeaponResource

# Ammo
const AMMO_TYPES:Array = [ 
		"Fire", 
		"Ice", 
	]

# Weapons
enum eWeaponsType { Gun, SMG } # AssaultRifle,
const WEAPONS_NAME:Dictionary = {
	eWeaponsType.Gun : "gun",
	eWeaponsType.SMG : "smg",
	#eWeaponsType.AssaultRifle : "gun",
}

const WEAPONS_SETTINGS:Dictionary = {
	eWeaponsType.Gun: {
		"Damage": {
			"Min": 7,
			"Max": 10,
		},
		"Rate": {
			"Min": 90,
			"Max": 120,
		},
	},
	eWeaponsType.SMG: {
		"Damage": {
			"Min": 10,
			"Max": 15,
		},
		"Rate": {
			"Min": 150,
			"Max": 180,
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