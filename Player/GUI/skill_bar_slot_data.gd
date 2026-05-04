extends Resource
class_name SkillBarSlotData

@export var weapon_id: String = ""
@export var icon: Texture2D
@export var sprite_sheet: Texture2D
@export var sprite_region: Rect2 = Rect2(0, 0, 0, 0)
@export var key_label: String = ""
@export var icon_scale: float = 0.75
@export var level_prop: String = ""
@export var attackspeed_prop: String = ""
@export var cooldown_prop: String = ""

func get_level_prop() -> String:
	if level_prop != "":
		return level_prop
	if weapon_id == "":
		return ""
	return "%s_level" % weapon_id

func get_attackspeed_prop() -> String:
	if attackspeed_prop != "":
		return attackspeed_prop
	if weapon_id == "":
		return ""
	return "%s_attackspeed" % weapon_id

func get_cooldown_prop() -> String:
	if cooldown_prop != "":
		return cooldown_prop
	if weapon_id == "":
		return ""
	return "%s_cooldown" % weapon_id
