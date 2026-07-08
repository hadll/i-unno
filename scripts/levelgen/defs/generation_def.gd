class_name GenerationDef
extends Resource

## max size of the map (origin is not 0)
@export var map_size: Vector2i
## starting room
@export var start: RoomDef
## sections, in order
@export var sections: Array[SectionDef]
## scenes for door types
@export var door_scenes: Dictionary[LevelGenerator.DoorType, PackedScene]
