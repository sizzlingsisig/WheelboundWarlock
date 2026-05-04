extends Area2D

const BASE_ORBIT_RADIUS = 56.0
const BASE_ORB_RADIUS = 10.0

var player = null
var orb_index = 0
var orb_total = 1
var level = 1
var hit_cooldown = 0.8
var damage = 4
var knockback_amount = 80
var orbit_speed = 2.6
var orbit_radius = BASE_ORBIT_RADIUS
var base_angle = 0.0

var enemy_next_hit = {}

@onready var collision = $CollisionShape2D

func configure_orb(owner_player, index, total, new_level, new_hit_cooldown):
	player = owner_player
	orb_index = index
	orb_total = max(total, 1)
	level = new_level
	hit_cooldown = max(new_hit_cooldown, 0.05)
	base_angle = (TAU / float(orb_total)) * float(orb_index)
	
	var spell_size = 0.0
	if player != null:
		spell_size = player.spell_size
	var level_data = UpgradeDb.get_weapon_level_data("willowhisp", level)
	if level_data != null:
		damage = level_data.damage
		if level_data.orbit_speed > 0.0:
			orbit_speed = level_data.orbit_speed
	else:
		match level:
			1:
				damage = 4
				orbit_speed = 2.6
			2:
				damage = 5
				orbit_speed = 2.8
			3:
				damage = 6
				orbit_speed = 3.0
			4:
				damage = 8
				orbit_speed = 3.2
	
	orbit_radius = BASE_ORBIT_RADIUS * (1.0 + spell_size * 0.4)
	if collision.shape is CircleShape2D:
		collision.shape.radius = BASE_ORB_RADIUS * (1.0 + spell_size * 0.25)
	queue_redraw()

func _physics_process(_delta):
	if not is_instance_valid(player):
		queue_free()
		return
	var now = Time.get_ticks_msec() / 1000.0
	var current_angle = base_angle + now * orbit_speed
	global_position = player.global_position + Vector2.RIGHT.rotated(current_angle) * orbit_radius
	rotation = current_angle
	apply_damage(now)

func apply_damage(now):
	for body in get_overlapping_bodies():
		if not is_instance_valid(body):
			continue
		if body.is_queued_for_deletion():
			continue
		if not body.has_method("_on_hurt_box_hurt"):
			continue
		var body_id = body.get_instance_id()
		var next_hit_time = enemy_next_hit.get(body_id, 0.0)
		if now < next_hit_time:
			continue
		var knockback_direction = player.global_position.direction_to(body.global_position)
		body._on_hurt_box_hurt(damage, knockback_direction, knockback_amount)
		enemy_next_hit[body_id] = now + hit_cooldown

func _draw():
	var orb_radius = BASE_ORB_RADIUS
	if collision.shape is CircleShape2D:
		orb_radius = collision.shape.radius
	draw_circle(Vector2.ZERO, orb_radius, Color(0.72, 0.86, 1.0, 0.95))
	draw_arc(Vector2.ZERO, orb_radius, 0.0, TAU, 24, Color(0.45, 0.62, 1.0, 1.0), 2.0)
