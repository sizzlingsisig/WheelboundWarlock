extends Control

const SkillBarSlotData = preload("res://Player/GUI/skill_bar_slot_data.gd")

@export var slot_scene: PackedScene
@export var slots: Array[SkillBarSlotData] = []

@onready var player = get_tree().get_first_node_in_group("player")
@onready var container = $VBoxContainer

var slot_views: Array = []
var _player_props: Dictionary = {}

func _ready():
	container.add_theme_constant_override("separation", 4)
	_build_slots()

func _process(_delta):
	var level_up_visible = get_node_or_null("%LevelUp")
	var should_hide = GameState.is_paused() or (level_up_visible and level_up_visible.visible)
	visible = not should_hide
	
	if not should_hide:
		update_cooldown_state()

func _build_slots():
	for child in container.get_children():
		child.queue_free()

	slot_views.clear()
	if slot_scene == null:
		return

	for slot_data in slots:
		if slot_data == null:
			continue
		var slot_instance = slot_scene.instantiate()
		container.add_child(slot_instance)

		var key_label = slot_instance.get_node_or_null("KeyLabel")
		if key_label and slot_data.key_label != "":
			key_label.text = slot_data.key_label

		var icon = slot_instance.get_node_or_null("Frame/IconMargin/Icon")
		if icon:
			var icon_texture = _get_slot_icon_texture(slot_data)
			if icon_texture:
				icon.texture = icon_texture
			_apply_icon_scale(icon, slot_data.icon_scale)

		var cooldown_label = slot_instance.get_node_or_null("CooldownLabel")
		var level_label = slot_instance.get_node_or_null("LevelLabel")
		var locked_label = slot_instance.get_node_or_null("LockedLabel")
		slot_views.append({
			"data": slot_data,
			"icon": icon,
			"cooldown_label": cooldown_label,
			"level_label": level_label,
			"locked_label": locked_label,
		})

	_cache_player_properties()

func _cache_player_properties():
	_player_props.clear()
	if player == null:
		return

	for prop in player.get_property_list():
		if prop.has("name"):
			_player_props[prop["name"]] = true

func _get_player_value(prop_name: String, default_value):
	if prop_name == "":
		return default_value
	if player == null:
		return default_value
	if _player_props.is_empty():
		_cache_player_properties()
	if not _player_props.has(prop_name):
		return default_value
	return player.get(prop_name)

func update_cooldown_state():
	if player == null:
		return
	if slot_views.is_empty():
		return

	for view in slot_views:
		var slot_data: SkillBarSlotData = view["data"]
		if slot_data == null:
			continue

		var level_prop = slot_data.get_level_prop()
		var cooldown_prop = slot_data.get_cooldown_prop()

		var level = _get_player_value(level_prop, 0)
		var cooldown = _get_player_value(cooldown_prop, 0.0)

		var cooldown_text = ""
		if cooldown > 0.0:
			if cooldown < 1.0:
				cooldown_text = "%.1f" % cooldown
			else:
				cooldown_text = str(int(ceil(cooldown)))

		var cooldown_label = view["cooldown_label"]
		if cooldown_label:
			cooldown_label.text = cooldown_text if level > 0 else ""
			cooldown_label.visible = cooldown_text != "" and level > 0

		var level_label = view["level_label"]
		if level_label:
			level_label.text = str(level) if level > 0 else ""

		var locked_label = view["locked_label"]
		if locked_label:
			locked_label.visible = level <= 0

		var icon_node = view["icon"]
		if icon_node:
			icon_node.modulate.a = 1.0 if level > 0 else 0.3

func _apply_icon_scale(icon_node: TextureRect, scale_value: float):
	if icon_node == null:
		return
	if scale_value <= 0.0:
		scale_value = 1.0
	call_deferred("_apply_icon_scale_deferred", icon_node, scale_value)

func _apply_icon_scale_deferred(icon_node: TextureRect, scale_value: float):
	if icon_node == null:
		return
	icon_node.pivot_offset = icon_node.size * 0.5
	icon_node.scale = Vector2(scale_value, scale_value)

func _get_slot_icon_texture(slot_data: SkillBarSlotData) -> Texture2D:
	if slot_data == null:
		return null
	if slot_data.sprite_sheet and slot_data.sprite_region.size != Vector2.ZERO:
		var atlas = AtlasTexture.new()
		atlas.atlas = slot_data.sprite_sheet
		atlas.region = slot_data.sprite_region
		return atlas
	return slot_data.icon
