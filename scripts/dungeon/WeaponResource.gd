class_name WeaponResource

# Ammo
const AMMO_TYPES:Array = [ 
		"Fire", 
		"Ice", 
	]

# Weapons
enum eWeaponsType { Gun, AssaultRifle, SMG }
const WEAPONS_NAME:Dictionary = {
	eWeaponsType.Gun : "gun",
	eWeaponsType.AssaultRifle : "gun",
	eWeaponsType.SMG : "gun",
}

const WEAPONS_SETTINGS:Dictionary = {
	eWeaponsType.Gun: {
		"Damage": {
			"Min": 10,
			"Max": 15,
		},
		"Rate": {
			"Min": 60,
			"Max": 70,
		},
	},
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
	eWeaponsType.SMG: {
		"Damage": {
			"Min": 15,
			"Max": 20,
		},
		"Rate": {
			"Min": 80,
			"Max": 100,
		},
	},
}