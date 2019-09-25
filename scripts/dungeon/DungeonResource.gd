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
	9:
		{
			5: [
				preload("res://prefabs/environment/dungeon/room/Prefab_9x5_0.tscn"),
				preload("res://prefabs/environment/dungeon/room/Prefab_9x5_1.tscn"),
			],
		},
	}

const ROOM_BACKGROUND:Dictionary = {
	9:
		{
			5: [
				preload("res://models/Rooms/room00.glb"),
				preload("res://models/Rooms/room01.glb"),
				preload("res://models/Rooms/room02.glb"),
				preload("res://models/Rooms/room03.glb"),
				preload("res://models/Rooms/room04.glb"),
			],
		},
	}

const KEYS_RESOURCES:Array = [
		preload("res://objects/keys/DoorKey/DoorKey.tscn"),
	]

const MOB_RESOURCES:Array = [
		preload("res://characters/Mobs/MobTentacle/MobTentacle.tscn"),
		#preload("res://characters/Mobs/Drone/Drone.tscn"),
		preload("res://characters/Mobs/Fly/Fly.tscn"),
	]

const IN_OUT_DOOR:Array = [
		preload("res://objects/doors/DungeonExit/DungeonExit.tscn")
	]
	
const INTERIOR_DOORS:Array = [
		preload("res://objects/doors/DungeonPipe/DungeonPipe00.tscn"),
	]