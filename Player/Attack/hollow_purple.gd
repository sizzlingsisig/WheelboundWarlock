extends Area2D

const BASE_RADIUS = 36.0

var level = 1
var damage = 4
var knockback_amount = 70
var attack_size = 1.0
var hit_interval = 0.35

var enemy_next_hit = {}

@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision = $CollisionShape2D

func _ready():
	update_hollow_purple(level)

func update_hollow_purple(new_level):
	level = new_level
	var spell_size = 0.0
	if player != null:
		spell_size = player.spell_size
	match level:
		1:
			damage = 4
			attack_size = 1.0 * (1 + spell_size)
		2:
			damage = 5
			attack_size = 1.2 * (1 + spell_size)
		3:
			damage = 7
			attack_size = 1.35 * (1 + spell_size)
		4:
			damage = 9
			attack_size = 1.5 * (1 + spell_size)
	if collision.shape is CircleShape2D:
		collision.shape.radius = BASE_RADIUS * attack_size
	queue_redraw()

func _physics_process(_delta):
	var now = Time.get_ticks_msec() / 1000.0
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
		var knockback_direction = global_position.direction_to(body.global_position)
		body._on_hurt_box_hurt(damage, knockback_direction, knockback_amount)
		enemy_next_hit[body_id] = now + hit_interval

func _draw():
	var radius = BASE_RADIUS * attack_size
	draw_circle(Vector2.ZERO, radius, Color(0.55, 0.2, 0.8, 0.25))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(0.82, 0.58, 1.0, 0.95), 2.0)
