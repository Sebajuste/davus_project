class_name DungeonResource

# Tiles
enum eTilesType { 
		Empty = -1,
		Door = 0,
		Wall = 1,
		Ladder = 2,
		PipeStraight = 3,
		PipeTurn = 4,
		# DEBUG :
			DoorInsertion = 5,
	}
	
const STATIC_BODIES:Dictionary = { 
		eTilesType.Wall: preload("res://tileset/Dungeon/Wall.tscn"),
		eTilesType.Ladder: preload("res://tileset/Dungeon/RightLadder.tscn"),
	}

# Doors
const IN_OUT_DOOR:Array = [
		preload("res://objects/doors/DungeonExit/DungeonExit.tscn")
	]

const INTERIOR_DOORS:Array = [
		preload("res://objects/doors/DungeonPipe/DungeonPipe00.tscn"),
	]

# Ammo
const AMMO_TYPES:Array = [ 
		"Fire", 
		"Ice", 
	]

# Keys/Rack
enum eUnlockableTypes { Key = 0, Rack = 1 }
const KEYS_RESOURCES:Array = [
		preload("res://objects/keys/DoorKey/DoorKey.tscn"),
	]
const RACK_RESOURCES:Array = [
		preload("res://objects/chests/WeaponRack/WeaponRack.tscn"),
	]


# Platforms
const PLATFORMS_RESOURCES:Array = [
		preload("res://models/Dungeon/Platform.glb"),
	]

# Rooms
const ROOM_PREFAB:Dictionary = {
	9:
		{
			5: [
				preload("res://prefabs/environment/dungeon/room/Prefab_9x5_0.tscn"),
				preload("res://prefabs/environment/dungeon/room/Prefab_9x5_1.tscn"),
				preload("res://prefabs/environment/dungeon/room/Prefab_9x5_2.tscn"),
				preload("res://prefabs/environment/dungeon/room/Prefab_9x5_3.tscn"),
				preload("res://prefabs/environment/dungeon/room/Prefab_9x5_4.tscn"),
			],
		},
	}

const EXTREMITIES_ROOM_BACKGROUND:Dictionary = {
	9:
		{
			5: [
				preload("res://models/Rooms/room00.glb"),
			],
		},
	}

const ROOM_BACKGROUND:Dictionary = {
	9:
		{
			5: [
				preload("res://models/Rooms/room01.glb"),
				preload("res://models/Rooms/room02.glb"),
				preload("res://models/Rooms/room03.glb"),
				preload("res://models/Rooms/room04.glb"),
			],
		},
	}

# Mobs
enum eMobType { Floor = 0, Fly = 1 }
const MOB_RESOURCES:Dictionary = {
		eMobType.Floor: [
			preload("res://characters/Mobs/MobTentacle/MobTentacle.tscn"),
		],
		eMobType.Fly: [
			preload("res://characters/Mobs/Drone/Drone.tscn"),
			preload("res://characters/Mobs/Fly/Fly.tscn"),
		],
	}