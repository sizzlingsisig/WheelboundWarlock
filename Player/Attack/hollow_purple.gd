extends Area2D

const BASE_RADIUS = 50.0

var level = 1
var damage = 4
var knockback_amount = 70
var attack_size = 1.0
var hit_interval = 0.35

var enemy_next_hit = {}
var rotation_angle = 0.0
var pulse_time = 0.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision = $CollisionShape2D

func _ready():
	pass

func on_spawn() -> void:
	update_hollow_purple(level)
	enemy_next_hit.clear()
	rotation_angle = 0.0
	pulse_time = 0.0

func update_hollow_purple(new_level):
	level = new_level
	var spell_size = 0.0
	if player != null:
		spell_size = player.spell_size
	match level:
		1:
			damage = 4
			attack_size = 1.4 * (1 + spell_size)
		2:
			damage = 5
			attack_size = 1.6 * (1 + spell_size)
		3:
			damage = 7
			attack_size = 1.8 * (1 + spell_size)
		4:
			damage = 9
			attack_size = 2.0 * (1 + spell_size)
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = BASE_RADIUS * attack_size

func _physics_process(delta):
	if is_instance_valid(player):
		global_position = player.global_position
	rotation_angle += delta * 0.8
	pulse_time += delta
	queue_redraw()
	
	var now = Time.get_ticks_msec() / 1000.0
	for body in get_overlapping_bodies():
		if not is_instance_valid(body):
			continue
		if body.is_queued_for_deletion():
			continue
		if body == player:
			continue
		if not body.has_method("_on_hurt_box_hurt"):
			continue
		var body_id = body.get_instance_id()
		var next_hit_time = enemy_next_hit.get(body_id, 0.0)
		if now < next_hit_time:
			continue
		var knockback_direction = global_position.direction_to(body.global_position)
		body._on_hurt_box_hurt(damage, knockback_direction, knockback_amount)
		enemy_next_hit[body_id] = now + hit_interval

func _draw():
	var base_r = BASE_RADIUS * attack_size
	var pulse = 1.0 + sin(pulse_time * 3.0) * 0.1
	var r = base_r * pulse
	
	var glow_color = Color(0.95, 0.5, 1.0, 0.15)
	draw_circle(Vector2.ZERO, r + 20, glow_color)
	draw_circle(Vector2.ZERO, r + 10, glow_color)
	
	var main_ring_color = Color(1.0, 0.6, 1.0, 0.9)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, main_ring_color, 5.0)
	
	var inner_color = Color(0.8, 0.4, 0.9, 0.6)
	draw_arc(Vector2.ZERO, r - 15, 0.0, TAU, 48, inner_color, 3.0)
	
	var outer_glow = Color(0.7, 0.3, 0.8, 0.4)
	draw_arc(Vector2.ZERO, r + 8, 0.0, TAU, 32, outer_glow, 2.0)

func _return_to_pool() -> void:
	var pool = get_tree().get_first_node_in_group("projectile_pool")
	if pool:
		pool.return_projectile("hollow_purple", self)
	else:
		queue_free()

func reset_state() -> void:
	enemy_next_hit.clear()
	rotation_angle = 0.0
	pulse_time = 0.0
