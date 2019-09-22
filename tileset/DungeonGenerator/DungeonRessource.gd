class_name DungeonRessource

enum eTilesType { 
		Empty = -1, 
		Door = 0, 
		Wall = 1, 
		Key = 2, 
		Start = 3, 
		End = 4, 
		DoorInsertion = 5, 
		LeftLadder = 6, 
		RightLadder = 7,  
		PipeStraight = 8,
		PipeTurn = 9,
	}
const STATIC_BODIES:Dictionary = { 
		eTilesType.Door: preload("res://tileset/test/Door.tscn"),
		eTilesType.Wall: preload("res://tileset/test/Wall.tscn"),
		eTilesType.LeftLadder: preload("res://tileset/test/LeftLadder.tscn"),
		eTilesType.RightLadder: preload("res://tileset/test/RightLadder.tscn"),
	}

const ROOM_PREFAB:Dictionary = {
	5:
		{
			3: preload("res://tileset/test/Prefab_5x3.tscn"),
			4: preload("res://tileset/test/Prefab_5x4.tscn"),
		},
	6:
		{
			3: preload("res://tileset/test/Prefab_6x3.tscn"),
		},
	7:
		{
			3: preload("res://tileset/test/Prefab_7x3.tscn"),
		},
	8:
		{
			3: preload("res://tileset/test/Prefab_8x3.tscn"),
		},
	}

const MOB_RESOURCES:Array = [
		preload("res://tileset/test/MobSpawn.tscn"),
	]