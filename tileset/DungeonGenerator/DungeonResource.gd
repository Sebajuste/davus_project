class_name DungeonResource

enum eTilesType { 
		Empty = -1, 
		Door = 0, 
		Wall = 1, 
		Ladder = 2,   
		PipeStraight = 3,
		PipeTurn = 4,
		# DEBUG :
			Key = 5, 
			Start = 6, 
			End = 7, 
			DoorInsertion = 8, 
	}
const STATIC_BODIES:Dictionary = { 
		eTilesType.Door: preload("res://tileset/test/Door.tscn"),
		eTilesType.Wall: preload("res://tileset/test/Wall.tscn"),
		eTilesType.Ladder: preload("res://tileset/test/RightLadder.tscn"),
	}

const ROOM_PREFAB:Dictionary = {
	5:
		{
			3: [
				preload("res://tileset/test/Prefab_5x3.tscn"),
			],
			4: [
				preload("res://tileset/test/Prefab_5x4.tscn"),
			],
		},
	6:
		{
			3: [
				preload("res://tileset/test/Prefab_6x3.tscn"),
			],
		},
	7:
		{
			3: [
				preload("res://tileset/test/Prefab_7x3.tscn"),
			],
		},
	8:
		{
			3: [
				preload("res://tileset/test/Prefab_8x3.tscn"),
			],
		},
	9:
		{
			5: [
				preload("res://tileset/test/Prefab_9x5_0.tscn"),
				preload("res://tileset/test/Prefab_9x5_1.tscn"),
			],
		},
	}

const MOB_RESOURCES:Array = [
		preload("res://characters/Mobs/MobTentacle/MobTentacle.tscn"),
		preload("res://characters/Mobs/Drone/Drone.tscn"),
		preload("res://characters/Mobs/Fly/Fly.tscn"),
	]

const IN_OUT_DOOR = preload("res://objects/doors/DungeonExit/DungeonExit.tscn")
const INTERIOR_DOORS:Array = [
		preload("res://models/Dungeon/Pipes/PipeDoor00.tscn"),
		preload("res://models/Dungeon/Pipes/PipeDoor01.tscn"),
	]
