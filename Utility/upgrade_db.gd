extends Node

const WEAPON_RESOURCE_DIR = "res://Resources/Weapons"

var _weapon_resources: Dictionary = {}
var _resource_upgrades_cache: Dictionary = {}


const ICON_PATH = "res://Textures/Items/Upgrades/"
const WEAPON_PATH = "res://Textures/Items/Weapons/"
const SPECIAL_WEAPON_PATH = "res://assets/kalboWheelchair/"
const SPRITESHEET_PATH = "res://assets/kalboWheelchair/spritesheets.png"

const SPRITE_REGION = {
	"icespear": Rect2i(16, 32, 16, 16),
	"tornado": Rect2i(48, 112, 16, 16),
	"immolate": Rect2i(64, 0, 16, 16),
	"hollowpurple": Rect2i(64, 64, 16, 16),
	"willowhisp": Rect2i(16, 128, 16, 16),
	"lightning": Rect2i(0, 16, 16, 16),
}

const UPGRADES = {
	"icespear1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["icespear"],
		"displayname": "Ice Spear",
		"details": "A spear of ice is thrown at a random enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"icespear2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["icespear"],
		"displayname": "Ice Spear",
		"details": "An addition Ice Spear is thrown",
		"level": "Level: 2",
		"prerequisite": ["icespear1"],
		"type": "weapon"
	},
	"icespear3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Ice Spear",
		"details": "Ice Spears now pass through another enemy and do + 3 damage",
		"level": "Level: 3",
		"prerequisite": ["icespear2"],
		"type": "weapon"
	},
	"icespear4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Ice Spear",
		"details": "An additional 2 Ice Spears are thrown",
		"level": "Level: 4",
		"prerequisite": ["icespear3"],
		"type": "weapon"
	},
	"javelin1": {
		"icon": WEAPON_PATH + "javelin_3_new.png",
		"displayname": "Javelin",
		"details": "A magical javelin will follow you attacking enemies in a straight line",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"javelin2": {
		"icon": WEAPON_PATH + "javelin_3_new.png",
		"displayname": "Javelin",
		"details": "The javelin will now attack an additional enemy per attack",
		"level": "Level: 2",
		"prerequisite": ["javelin1"],
		"type": "weapon"
	},
	"javelin3": {
		"icon": WEAPON_PATH + "javelin_3_new.png",
		"displayname": "Javelin",
		"details": "The javelin will attack another additional enemy per attack",
		"level": "Level: 3",
		"prerequisite": ["javelin2"],
		"type": "weapon"
	},
	"javelin4": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"displayname": "Javelin",
		"details": "The javelin now does + 5 damage per attack and causes 20% additional knockback",
		"level": "Level: 4",
		"prerequisite": ["javelin3"],
		"type": "weapon"
	},
	"tornado1": {
		"icon": WEAPON_PATH + "tornado.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["tornado"],
		"displayname": "Tornado",
		"details": "A tornado is created and random heads somewhere in the players direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"tornado2": {
		"icon": WEAPON_PATH + "tornado.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["tornado"],
		"displayname": "Tornado",
		"details": "An additional Tornado is created",
		"level": "Level: 2",
		"prerequisite": ["tornado1"],
		"type": "weapon"
	},
	"tornado3": {
		"icon": WEAPON_PATH + "tornado.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["tornado"],
		"displayname": "Tornado",
		"details": "The Tornado cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisite": ["tornado2"],
		"type": "weapon"
	},
	"tornado4": {
		"icon": WEAPON_PATH + "tornado.png",
		"displayname": "Tornado",
		"details": "An additional tornado is created and the knockback is increased by 25%",
		"level": "Level: 4",
		"prerequisite": ["tornado3"],
		"type": "weapon"
	},
	"lightning1": {
		"icon": SPECIAL_WEAPON_PATH + "lightningicon.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["lightning"],
		"displayname": "Lightning",
		"details": "Lightning strikes and chains to 1 nearby enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"lightning2": {
		"icon": SPECIAL_WEAPON_PATH + "lightningicon.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["lightning"],
		"displayname": "Lightning",
		"details": "Lightning chains to 1 additional enemy",
		"level": "Level: 2",
		"prerequisite": ["lightning1"],
		"type": "weapon"
	},
	"lightning3": {
		"icon": SPECIAL_WEAPON_PATH + "lightningicon.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["lightning"],
		"displayname": "Lightning",
		"details": "Lightning damage increased by 3",
		"level": "Level: 3",
		"prerequisite": ["lightning2"],
		"type": "weapon"
	},
	"lightning4": {
		"icon": SPECIAL_WEAPON_PATH + "lightningicon.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["lightning"],
		"displayname": "Lightning",
		"details": "Lightning chains to 1 additional enemy",
		"level": "Level: 4",
		"prerequisite": ["lightning3"],
		"type": "weapon"
	},
	"immolate1": {
		"icon": SPECIAL_WEAPON_PATH + "fire_column_medium/fire_column_medium_1.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["immolate"],
		"displayname": "Immolate",
		"details": "Surround yourself in fire - damages enemies on contact and increases speed",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"immolate2": {
		"icon": SPECIAL_WEAPON_PATH + "fire_column_medium/fire_column_medium_1.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["immolate"],
		"displayname": "Immolate",
		"details": "Increased speed and +1 damage",
		"level": "Level: 2",
		"prerequisite": ["immolate1"],
		"type": "weapon"
	},
	"immolate3": {
		"icon": SPECIAL_WEAPON_PATH + "fire_column_medium/fire_column_medium_1.png",
		"displayname": "Immolate",
		"details": "Larger area and longer duration",
		"level": "Level: 3",
		"prerequisite": ["immolate2"],
		"type": "weapon"
	},
	"immolate4": {
		"icon": SPECIAL_WEAPON_PATH + "fire_column_medium/fire_column_medium_1.png",
		"displayname": "Immolate",
		"details": "Maximum damage, speed, and area",
		"level": "Level: 4",
		"prerequisite": ["immolate3"],
		"type": "weapon"
	},
	"hollowpurple1": {
		"icon": SPECIAL_WEAPON_PATH + "Dark-Bolt.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["hollowpurple"],
		"displayname": "Hollow Purple",
		"details": "A persistent purple radius damages enemies around you",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"hollowpurple2": {
		"icon": SPECIAL_WEAPON_PATH + "Dark-Bolt.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["hollowpurple"],
		"displayname": "Hollow Purple",
		"details": "Hollow Purple radius grows larger",
		"level": "Level: 2",
		"prerequisite": ["hollowpurple1"],
		"type": "weapon"
	},
	"hollowpurple3": {
		"icon": SPECIAL_WEAPON_PATH + "Dark-Bolt.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["hollowpurple"],
		"displayname": "Hollow Purple",
		"details": "Hollow Purple damage and size increase",
		"level": "Level: 3",
		"prerequisite": ["hollowpurple2"],
		"type": "weapon"
	},
	"hollowpurple4": {
		"icon": SPECIAL_WEAPON_PATH + "Dark-Bolt.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["hollowpurple"],
		"displayname": "Hollow Purple",
		"details": "Hollow Purple reaches maximum size and damage",
		"level": "Level: 4",
		"prerequisite": ["hollowpurple3"],
		"type": "weapon"
	},
	"willowhisp1": {
		"icon": SPECIAL_WEAPON_PATH + "spark.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["willowhisp"],
		"displayname": "Will O Whisps",
		"details": "A single orb rotates around you and damages enemies",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"willowhisp2": {
		"icon": SPECIAL_WEAPON_PATH + "spark.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": SPRITE_REGION["willowhisp"],
		"displayname": "Will O Whisps",
		"details": "Orb hit cooldown is reduced",
		"level": "Level: 2",
		"prerequisite": ["willowhisp1"],
		"type": "weapon"
	},
	"willowhisp3": {
		"icon": SPECIAL_WEAPON_PATH + "spark.png",
		"displayname": "Will O Whisps",
		"details": "An additional orb rotates around you",
		"level": "Level: 3",
		"prerequisite": ["willowhisp2"],
		"type": "weapon"
	},
	"willowhisp4": {
		"icon": SPECIAL_WEAPON_PATH + "spark.png",
		"displayname": "Will O Whisps",
		"details": "Another orb is added and hit cooldown is reduced",
		"level": "Level: 4",
		"prerequisite": ["willowhisp3"],
		"type": "weapon"
	},
	"armor1": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"tome1": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"tome2": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 2",
		"prerequisite": ["tome1"],
		"type": "upgrade"
	},
	"tome3": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 3",
		"prerequisite": ["tome2"],
		"type": "upgrade"
	},
	"tome4": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 4",
		"prerequisite": ["tome3"],
		"type": "upgrade"
	},
	"scroll1": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"scroll2": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 2",
		"prerequisite": ["scroll1"],
		"type": "upgrade"
	},
	"scroll3": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 3",
		"prerequisite": ["scroll2"],
		"type": "upgrade"
	},
	"scroll4": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 4",
		"prerequisite": ["scroll3"],
		"type": "upgrade"
	},
	"ring1": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn 1 more additional attack",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"ring2": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn an additional attack",
		"level": "Level: 2",
		"prerequisite": ["ring1"],
		"type": "upgrade"
	},
	"magnet1": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 160, 16, 16),
		"displayname": "Hand of Midas",
		"details": "Increases XP gem pickup range by 25",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"magnet2": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 160, 16, 16),
		"displayname": "Hand of Midas",
		"details": "Increases XP gem pickup range by an additional 25",
		"level": "Level: 2",
		"prerequisite": ["magnet1"],
		"type": "upgrade"
	},
	"magnet3": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 160, 16, 16),
		"displayname": "Hand of Midas",
		"details": "Increases XP gem pickup range by an additional 25",
		"level": "Level: 3",
		"prerequisite": ["magnet2"],
		"type": "upgrade"
	},
	"magnet4": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 160, 16, 16),
		"displayname": "Hand of Midas",
		"details": "Increases XP gem pickup range by an additional 50",
		"level": "Level: 4",
		"prerequisite": ["magnet3"],
		"type": "upgrade"
	},
	"heart troll1": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 144, 16, 16),
		"displayname": "Heart of a Troll",
		"details": "Regenerates 0.5 HP per second",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"heart troll2": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 144, 16, 16),
		"displayname": "Heart of a Troll",
		"details": "Regenerates an additional 0.5 HP per second",
		"level": "Level: 2",
		"prerequisite": ["heart troll1"],
		"type": "upgrade"
	},
	"heart troll3": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 144, 16, 16),
		"displayname": "Heart of a Troll",
		"details": "Regenerates an additional 1 HP per second",
		"level": "Level: 3",
		"prerequisite": ["heart troll2"],
		"type": "upgrade"
	},
	"heart troll4": {
		"icon": SPECIAL_WEAPON_PATH + "spritesheets.png",
		"sprite_sheet": SPRITESHEET_PATH,
		"sprite_region": Rect2i(0, 144, 16, 16),
		"displayname": "Heart of a Troll",
		"details": "Regenerates an additional 1.5 HP per second",
		"level": "Level: 4",
		"prerequisite": ["heart troll3"],
		"type": "upgrade"
	},
	"food": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Food",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}
}

func _load_weapon_resources() -> void:
	if _weapon_resources.size() > 0:
		return
	var dir = DirAccess.open(WEAPON_RESOURCE_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var ext = file_name.get_extension()
			if ext == "tres" or ext == "res":
				var resource_path = WEAPON_RESOURCE_DIR + "/" + file_name
				var resource = load(resource_path)
				if resource is WeaponData and resource.id != "":
					_weapon_resources[resource.id] = resource
		file_name = dir.get_next()
	dir.list_dir_end()
	_build_resource_upgrade_cache()

func _build_resource_upgrade_cache() -> void:
	_resource_upgrades_cache.clear()
	for weapon_id in _weapon_resources:
		var weapon: WeaponData = _weapon_resources[weapon_id]
		if weapon == null or weapon.levels.is_empty():
			continue
		for level_data in weapon.levels:
			if level_data == null:
				continue
			var level_num = level_data.level
			if level_num <= 0:
				continue
			var key = "%s%d" % [weapon.id, level_num]
			var prereq = level_data.prerequisites
			if prereq.is_empty() and level_num > 1:
				prereq = ["%s%d" % [weapon.id, level_num - 1]]
			_resource_upgrades_cache[key] = {
				"icon": weapon.icon_path,
				"sprite_sheet": weapon.sprite_sheet_path,
				"sprite_region": weapon.sprite_region,
				"displayname": weapon.display_name,
				"details": level_data.description,
				"level": "Level: %d" % level_num,
				"prerequisite": prereq,
				"type": "weapon"
			}

func get_upgrade_ids() -> Array:
	_load_weapon_resources()
	var ids: Array = []
	for id in UPGRADES:
		ids.append(id)
	for id in _resource_upgrades_cache:
		if not ids.has(id):
			ids.append(id)
	return ids

func get_upgrade_data(id: String) -> Dictionary:
	_load_weapon_resources()
	if _resource_upgrades_cache.has(id):
		return _resource_upgrades_cache[id]
	return UPGRADES.get(id, {})

func get_weapon_resource(weapon_id: String) -> WeaponData:
	_load_weapon_resources()
	if _weapon_resources.has(weapon_id):
		return _weapon_resources[weapon_id]
	return null

func get_weapon_level_data(weapon_id: String, level: int) -> WeaponLevelData:
	var weapon = get_weapon_resource(weapon_id)
	if weapon == null:
		return null
	for level_data in weapon.levels:
		if level_data != null and level_data.level == level:
			return level_data
	return null
