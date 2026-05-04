extends Resource
class_name WeaponData

@export var id: String = ""
@export var display_name: String = ""
@export var icon_path: String = ""
@export var sprite_sheet_path: String = ""
@export var sprite_region: Rect2i = Rect2i()
@export var scene_path: String = ""
@export var levels: Array[WeaponLevelData] = []
