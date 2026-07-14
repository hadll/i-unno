class_name SectionDef
extends Resource

## name of this section
@export var name: String
## room weighting for this section
@export var rooms: Dictionary[RoomDef, float]
## final room of this section
@export var end: RoomDef
## requried rooms for this section
@export var required: Array[RoomDef]
@export_group("Layout")
## horizontal density required to finish this section
@export_range(0.0, 1.0, 0.01) var required_density: float
## rough spacing of holes placed in the layout
@export_range(0.0, 1.0, 0.01) var hole_density: float
## maximum size for holes
@export_range(0.0, 5.0, 0.5, "or_greater") var hole_size: float
## chance for a door to connect in a non essential way
@export_range(0.0, 1.0, 0.01) var extra_door_chance: float
## chance for a door to connect a pair of rooms that already have one
@export_range(0.0, 1.0, 0.01) var duplicate_door_chance: float
## higher values mean longer chains of rooms
@export_range(0.0, 0.9, 0.01) var sprawl: float
## end is placed past at least this portion of doors
@export_range(0.0, 0.9, 0.01) var end_depth: float
@export_group("Materials", "material_")
## material used for walls
@export var material_wall: Material
## material used for floors
@export var material_floor: Material
@export_group("Enemies", "enemy_")
## pool of enemies to spawn
@export var enemy_pool: Array[PackedScene]
## number of enemies to spawn
@export var enemy_count: int
