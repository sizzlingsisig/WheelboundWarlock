extends Control

const SkillBarSlotData = preload("res://Player/GUI/skill_bar_slot_data.gd")

@export var slots: Array[SkillBarSlotData] = []
@export var slot_size: Vector2 = Vector2(42, 42)
@export var slot_spacing: int = 6
@export var icon_padding: int = 4
@export var key_font_size: int = 9
@export var key_offset: Vector2 = Vector2(2, 1)

var player: Node
var slot_controls: Array[Control] = []
var icon_sprites: Array[Sprite2D] = []
var ring_controls: Array = []

@onready var container = $Slots

func _ready():
	container.add_theme_constant_override("separation", slot_spacing)
	_build_slots()
	call_deferred("_find_player")

func _find_player():
	var gui_canvas = get_parent()
	if gui_canvas and gui_canvas.get_parent():
		var player_node = gui_canvas.get_parent()
		if player_node:
			player = player_node.get_parent()

func _build_slots():
	for child in container.get_children():
		child.queue_free()
	
	slot_controls.clear()
	icon_sprites.clear()
	ring_controls.clear()

	for slot_data in slots:
		if slot_data == null:
			continue
		var slot_control = Control.new()
		slot_control.custom_minimum_size = slot_size
		slot_control.size = slot_size
		container.add_child(slot_control)
		slot_controls.append(slot_control)

		var key_label = Label.new()
		key_label.text = slot_data.key_label
		key_label.add_theme_font_size_override("font_size", key_font_size)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		key_label.position = key_offset
		key_label.z_index = 2
		slot_control.add_child(key_label)

		var icon_sprite = Sprite2D.new()
		icon_sprite.z_index = 0
		slot_control.add_child(icon_sprite)
		icon_sprites.append(icon_sprite)
		_setup_icon_sprite(icon_sprite, slot_data)

		var ring = CooldownRing.new()
		ring.custom_minimum_size = slot_size
		ring.size = slot_size
		ring.z_index = 1
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_control.add_child(ring)
		ring_controls.append(ring)

func _setup_icon_sprite(icon_sprite: Sprite2D, slot_data: SkillBarSlotData):
	var texture = _get_slot_icon_texture(slot_data)
	if texture == null:
		return

	icon_sprite.texture = texture
	icon_sprite.centered = true
	icon_sprite.position = slot_size * 0.5

	var source_size = _get_icon_source_size(texture, slot_data)
	if source_size.x > 0 and source_size.y > 0:
		var available = slot_size - Vector2(icon_padding * 2, icon_padding * 2)
		var scale_value = min(available.x / source_size.x, available.y / source_size.y)
		scale_value *= max(slot_data.icon_scale, 0.01)
		icon_sprite.scale = Vector2(scale_value, scale_value)

func _get_slot_icon_texture(slot_data: SkillBarSlotData) -> Texture2D:
	if slot_data.sprite_sheet and slot_data.sprite_region.size != Vector2.ZERO:
		var atlas = AtlasTexture.new()
		atlas.atlas = slot_data.sprite_sheet
		atlas.region = slot_data.sprite_region
		return atlas
	return slot_data.icon

func _get_icon_source_size(texture: Texture2D, slot_data: SkillBarSlotData) -> Vector2:
	if slot_data.sprite_sheet and slot_data.sprite_region.size != Vector2.ZERO:
		return slot_data.sprite_region.size
	return texture.get_size()

func _get_weapon_level(weapon_id: String) -> int:
	if not player:
		return 0
	match weapon_id:
		"icespear", "ice_spear": return player.icespear_level
		"tornado": return player.tornado_level
		"immolate": return player.immolate_level
		"lightning": return player.lightning_level
	return 0

func _get_weapon_cooldown(weapon_id: String) -> float:
	if not player:
		return 0.0
	match weapon_id:
		"icespear", "ice_spear": return player.icespear_cooldown
		"tornado": return player.tornado_cooldown
		"immolate": return player.immolate_cooldown
		"lightning": return player.lightning_cooldown
	return 0.0

func _get_max_cooldown(weapon_id: String) -> float:
	if not player:
		return 1.0
	match weapon_id:
		"icespear", "ice_spear": return player.icespear_attackspeed
		"tornado": return player.tornado_attackspeed
		"immolate": return player.immolate_attackspeed
		"lightning": return player.lightning_attackspeed
	return 1.0

func _process(_delta):
	if player:
		_update_slot_visuals()
	_update_cooldown_rings()

func _update_slot_visuals():
	if not player:
		return
	
	for i in range(slots.size()):
		if i >= slot_controls.size() or i >= icon_sprites.size():
			continue
		var slot_data = slots[i]
		if slot_data == null:
			continue
		
		var icon_sprite = icon_sprites[i]
		var level = _get_weapon_level(slot_data.weapon_id)
		
		if level == 0:
			icon_sprite.modulate = Color(0.2, 0.2, 0.2, 1.0)
		else:
			icon_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _update_cooldown_rings():
	if not player:
		return

	for i in range(slots.size()):
		if i >= ring_controls.size():
			continue
		var slot_data = slots[i]
		if slot_data == null:
			continue

		var cooldown = _get_weapon_cooldown(slot_data.weapon_id)
		var max_cooldown = _get_max_cooldown(slot_data.weapon_id)
		var level = _get_weapon_level(slot_data.weapon_id)

		var ring = ring_controls[i]
		if ring:
			if cooldown > 0 and level > 0 and max_cooldown > 0:
				ring.progress = 1.0 - (cooldown / max_cooldown)
				ring.visible = true
				ring.queue_redraw()
			else:
				ring.visible = false

class CooldownRing:
	extends Control

	var progress: float = 0.0
	var line_width: float = 2.0
	var line_color: Color = Color(1.0, 1.0, 1.0, 0.7)
	var fill_color: Color = Color(0.0, 0.0, 0.0, 0.35)

	func _draw():
		if progress <= 0:
			return
		var center = size * 0.5
		var radius = min(size.x, size.y) * 0.30
		_draw_circle_filled(center, radius * 0.85, progress, fill_color)

	func _draw_circle_arc(center: Vector2, radius: float, progress_value: float, width: float, color: Color):
		var segments = 32
		var start_angle = -PI / 2
		var end_angle = start_angle + (2 * PI * progress_value)
		for i in range(segments):
			var from_angle = lerp(start_angle, end_angle, float(i) / segments)
			var to_angle = lerp(start_angle, end_angle, float(i + 1) / segments)
			var from = center + Vector2(cos(from_angle), sin(from_angle)) * radius
			var to = center + Vector2(cos(to_angle), sin(to_angle)) * radius
			draw_line(from, to, color, width)

	func _draw_circle_filled(center: Vector2, radius: float, progress_value: float, color: Color):
		var points = PackedVector2Array()
		points.append(center)
		var segments = 32
		for i in range(segments + 1):
			var angle = -PI / 2 + (2 * PI * progress_value * float(i) / segments)
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		draw_polygon(points, [color])
