class_name SectionDef
extends Resource

@export var name: String
@export var rooms: Array[RoomDef]
@export var required_density: float
@export var end: RoomDef
@export_group("Materials", "material_")
@export var material_wall: Material
@export var material_floor: Material
