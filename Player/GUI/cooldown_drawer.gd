extends Control

var parent_slot_data: SkillBarSlotData
var parent_skill_bar: Control

func _ready():
	parent_skill_bar = get_parent()
	while parent_skill_bar and not parent_skill_bar.has_method("_get_weapon_cooldown"):
		parent_skill_bar = parent_skill_bar.get_parent()
		if parent_skill_bar is Control and "container" in parent_skill_bar:
			parent_skill_bar = parent_skill_bar.get_parent()
	
	var idx = 0
	if parent_skill_bar:
		var slots = parent_skill_bar.get("slots")
		if slots:
			var parent_control = get_parent()
			var container = parent_control.get_parent()
			if container:
				for i in range(slots.size()):
					if i < container.get_child_count():
						var child = container.get_child(i)
						if child == parent_control:
							idx = i
							break
				parent_slot_data = slots[idx] if idx < slots.size() else null

func _draw():
	if not parent_skill_bar or not parent_slot_data:
		return
	
	var player = parent_skill_bar.get("player")
	if not player:
		return
	
	var weapon_id = parent_slot_data.weapon_id
	var level = _get_weapon_level(player, weapon_id)
	var cooldown = _get_weapon_cooldown(player, weapon_id)
	var max_cooldown = _get_max_cooldown(player, weapon_id)
	
	if cooldown > 0 and level > 0:
		var progress = 1.0 - (cooldown / max_cooldown)
		var slot_size = parent_skill_bar.get("slot_size")
		var center = slot_size * 0.5
		var radius = min(slot_size.x, slot_size.y) * 0.45
		_draw_circle_arc(center, radius, progress, 2.0, Color(1.0, 1.0, 1.0, 0.7))
		_draw_circle_filled(center, radius, progress, Color(0.0, 0.0, 0.0, 0.5))

func _get_weapon_level(p: Node, wid: String) -> int:
	match wid:
		"icespear", "ice_spear": return p.icespear_level
		"tornado": return p.tornado_level
		"immolate": return p.immolate_level
		"lightning": return p.lightning_level
	return 0

func _get_weapon_cooldown(p: Node, wid: String) -> float:
	match wid:
		"icespear", "ice_spear": return p.icespear_cooldown
		"tornado": return p.tornado_cooldown
		"immolate": return p.immolate_cooldown
		"lightning": return p.lightning_cooldown
	return 0.0

func _get_max_cooldown(p: Node, wid: String) -> float:
	match wid:
		"icespear", "ice_spear": return p.icespear_attackspeed
		"tornado": return p.tornado_attackspeed
		"immolate": return p.immolate_attackspeed
		"lightning": return p.lightning_attackspeed
	return 1.0

func _draw_circle_arc(center: Vector2, radius: float, progress: float, line_width: float, color: Color):
	if progress <= 0:
		return
	var segments = 32
	var start_angle = -PI / 2
	var end_angle = start_angle + (2 * PI * progress)
	for i in range(segments):
		var from_angle = lerp(start_angle, end_angle, float(i) / segments)
		var to_angle = lerp(start_angle, end_angle, float(i + 1) / segments)
		var from = center + Vector2(cos(from_angle), sin(from_angle)) * radius
		var to = center + Vector2(cos(to_angle), sin(to_angle)) * radius
		draw_line(from, to, color, line_width)

func _draw_circle_filled(center: Vector2, radius: float, progress: float, color: Color):
	if progress <= 0:
		return
	var points = PackedVector2Array()
	var segments = 32
	points.append(center)
	for i in range(segments + 1):
		var angle = -PI / 2 + (2 * PI * progress * float(i) / segments)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_polygon(points, [color])