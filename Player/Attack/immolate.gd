extends Node2D

var level = 1
var damage = 3
var duration = 5.0

var enemy_next_hit = {}
var time_passed = 0.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var hit_area = $HitArea

func _ready():
	pass

func on_spawn() -> void:
	update_immolate(level)
	enemy_next_hit.clear()
	time_passed = 0.0
	$DurationTimer.wait_time = duration
	$DurationTimer.start()

func update_immolate(new_level):
	level = new_level
	var spell_size = 0.0
	if player != null:
		spell_size = player.spell_size
	
	match level:
		1:
			damage = 3
			duration = 5.0
		2:
			damage = 4
			duration = 6.0
		3:
			damage = 5
			duration = 7.0
		4:
			damage = 7
			duration = 8.0
	
	scale = Vector2(1.0, 1.0)

func _physics_process(_delta):
	time_passed += _delta
	if is_instance_valid(player):
		global_position = player.global_position
	queue_redraw()
	
	var now = Time.get_ticks_msec() / 1000.0
	for body in hit_area.get_overlapping_bodies():
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
		body._on_hurt_box_hurt(damage, knockback_direction, 80)
		enemy_next_hit[body_id] = now + 0.3

func _draw():
	var pulse = 1.0 + sin(time_passed * 6.0) * 0.15
	var base_scale = 1.5 * pulse
	
	var glow_color = Color(1.0, 0.3, 0.05, 0.1)
	draw_circle(Vector2.ZERO, 40 * base_scale, glow_color)
	draw_circle(Vector2.ZERO, 30 * base_scale, glow_color)
	
	for i in range(6):
		var angle = (TAU / 6) * i + time_passed * 2.5
		var wobble = sin(time_passed * 8.0 + i * 1.5) * 3.0
		var dist = 18.0 + wobble
		var pos = Vector2(cos(angle), sin(angle)) * dist
		draw_circle(pos, 6 * base_scale * 0.5, Color(1.0, 0.5, 0.1, 0.6))
		draw_circle(pos, 4 * base_scale * 0.5, Color(1.0, 0.8, 0.2, 0.8))

func _on_duration_timer_timeout():
	print("Immolate expired!")
	remove_speed_boost()
	_return_to_pool()

func remove_speed_boost():
	if is_instance_valid(player):
		player.movement_speed -= player.immolate_speed_boost
		player.immolate_active = false

func reset_state() -> void:
	enemy_next_hit.clear()
	time_passed = 0.0
	var timer = get_node_or_null("DurationTimer")
	if timer:
		timer.stop()

func on_despawn() -> void:
	var timer = get_node_or_null("DurationTimer")
	if timer:
		timer.stop()

func _return_to_pool() -> void:
	var pool = get_tree().get_first_node_in_group("projectile_pool")
	if pool:
		pool.return_projectile("immolate", self)
	else:
		queue_free()