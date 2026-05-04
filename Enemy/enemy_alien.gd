extends CharacterBody2D

enum State {
	SPAWN,
	MOVE,
	CHARGE_PREP,
	CHARGE,
	STUN,
	SLAM_PREP,
	SLAM,
	SLAM_RECOVER,
	PROJECTILE_PREP,
	PROJECTILE_RECOVER,
	TELEPORT_PREP,
	TELEPORT,
	TELEPORT_RECOVER,
	DEAD
}

enum Phase { ONE, TWO, THREE, FOUR }
enum AttackType { CHARGE, PROJECTILE, SLAM, TELEPORT, MINION }

@export var movement_speed = 50.0
@export var charge_speed = 100.0
@export var hp = 750
@export var max_hp = 750
@export var knockback_recovery = 25.0
@export var experience = 200
@export var enemy_damage = 15

@export var charge_interval = 5.0
@export var charge_prep_duration = 1.0
@export var charge_duration = 1.5
@export var stun_duration = 2.0
@export var minion_spawn_interval = 10.0
@export var projectile_interval = 8.0
@export var slam_interval = 12.0
@export var teleport_interval = 15.0
@export var projectile_prep_duration = 0.6
@export var projectile_recover_duration = 0.5
@export var slam_recover_duration = 0.6
@export var teleport_prep_duration = 0.3
@export var teleport_recover_duration = 0.5
@export var pattern_step_interval = 2.5
@export var cooldown_tax = 1.5
@export var hit_stop_duration = 0.05
@export var hit_vfx_cooldown = 0.12

var current_state: State = State.SPAWN
var state_timer: float = 0.0
var knockback = Vector2.ZERO
var charge_direction = Vector2.ZERO
var pattern_step_timer: float = 0.0
var minion_timer: float = 0.0
var projectile_timer: float = 0.0
var slam_timer: float = 0.0
var teleport_timer: float = 0.0
var is_invulnerable = false
var is_enraged = false
var enrage_multiplier = 1.5
var hit_stop_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var telegraph_tint_timer: float = 0.0
var telegraph_tint_color = Color.WHITE
var hit_vfx_timer: float = 0.0
var attack_cooldowns = {}
var pattern_index = 0
var pattern_random_every = 3
var current_move_animation = ""
var last_attack_type = -1
var last_attack_repeats = 0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var projectile_pool = get_tree().get_first_node_in_group("projectile_pool")
@onready var sprite = $AnimatedSprite2D
@onready var anim = $AnimationPlayer
@onready var hitBox = $HitBox
@onready var snd_telegraph = $snd_telegraph

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")
var weak_enemy_scene = preload("res://Enemy/enemy_kobold_weak.tscn")

signal remove_from_array(object)
signal boss_defeated

var glow_intensity = 0.0

func _ready():
	current_state = State.SPAWN
	state_timer = 0.0
	pattern_step_timer = 0.0
	minion_timer = 0.0
	projectile_timer = 0.0
	slam_timer = 0.0
	teleport_timer = 0.0
	attack_cooldowns = _build_attack_cooldowns()
	hitBox.damage = enemy_damage
	add_to_group("boss")
	spawn_effect()

func _process(delta):
	if hurt_flash_timer > 0.0:
		hurt_flash_timer = max(0.0, hurt_flash_timer - delta)
	if telegraph_tint_timer > 0.0:
		telegraph_tint_timer = max(0.0, telegraph_tint_timer - delta)
	if hit_vfx_timer > 0.0:
		hit_vfx_timer = max(0.0, hit_vfx_timer - delta)

	var base_color = Color.WHITE
	if current_state == State.MOVE:
		glow_intensity = (sin(Time.get_ticks_msec() * 0.003) + 1) * 0.15 + 0.85
		if is_enraged:
			var red_glow = glow_intensity * 1.2
			base_color = Color(red_glow, glow_intensity * 0.45, glow_intensity * 0.45)
		else:
			base_color = Color(glow_intensity, glow_intensity * 0.8, glow_intensity * 0.8)

	if telegraph_tint_timer > 0.0:
		base_color = base_color.lerp(telegraph_tint_color, 0.6)
	if hurt_flash_timer > 0.0:
		base_color = Color(2, 2, 2)

	sprite.modulate = base_color

func spawn_effect():
	scale = Vector2.ZERO
	modulate = Color(3, 3, 3)
	
	if is_instance_valid(player):
		player.screen_shake(0.5, 8.0)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 1.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.5)
	tween.tween_callback(func(): current_state = State.MOVE)
	
	for i in range(5):
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		var spawn_burst = death_anim.instantiate()
		spawn_burst.global_position = global_position + offset
		spawn_burst.scale = Vector2(1.5, 1.5)
		get_parent().add_child(spawn_burst)
		await get_tree().create_timer(0.1).timeout

func _physics_process(delta):
	if hit_stop_timer > 0.0:
		hit_stop_timer -= delta
		if hit_stop_timer <= 0.0:
			sprite.speed_scale = 1.0
			anim.speed_scale = 1.0
		return

	match current_state:
		State.SPAWN:
			_update_spawn(delta)
		State.MOVE:
			_update_move(delta)
		State.CHARGE_PREP:
			_update_charge_prep(delta)
		State.CHARGE:
			_update_charge(delta)
		State.STUN:
			_update_stun(delta)
		State.SLAM_PREP:
			_update_slam_prep(delta)
		State.SLAM:
			_update_slam(delta)
		State.SLAM_RECOVER:
			_update_slam_recover(delta)
		State.PROJECTILE_PREP:
			_update_projectile_prep(delta)
		State.PROJECTILE_RECOVER:
			_update_projectile_recover(delta)
		State.TELEPORT_PREP:
			_update_teleport_prep(delta)
		State.TELEPORT:
			_update_teleport(delta)
		State.TELEPORT_RECOVER:
			_update_teleport_recover(delta)
		State.DEAD:
			pass

func _update_spawn(delta: float) -> void:
	pass

func _update_move(delta: float) -> void:
	if is_invulnerable:
		return

	var phase = _get_phase()
	var speed_multiplier = _get_phase_speed_multiplier(phase)
	if is_enraged:
		speed_multiplier *= enrage_multiplier
	_tick_attack_cooldowns(delta)
	
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			_play_move_animation("move_right")
		else:
			_play_move_animation("move_left")
	else:
		if direction.y > 0:
			_play_move_animation("move_down")
		else:
			_play_move_animation("move_up")

	pattern_step_timer += delta
	if pattern_step_timer >= pattern_step_interval / speed_multiplier:
		var next_attack = _get_next_attack(phase, global_position.distance_to(player.global_position))
		if next_attack != -1:
			pattern_step_timer = 0.0
			_start_attack(next_attack, phase)

func _update_charge_prep(delta: float) -> void:
	state_timer += delta
	_chase_player(delta, 0.45)

	if state_timer >= charge_prep_duration:
		start_charge_attack()

func _update_charge(delta: float) -> void:
	state_timer += delta
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity = charge_direction * charge_speed
	velocity += knockback
	move_and_slide()

	if state_timer >= charge_duration:
		current_state = State.STUN
		state_timer = 0.0
		anim.play("stun")

func _update_stun(delta: float) -> void:
	state_timer += delta
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity = Vector2.ZERO
	move_and_slide()

	if state_timer >= stun_duration:
		pattern_step_timer = 0.0
		current_state = State.MOVE

func _update_slam_prep(delta: float) -> void:
	state_timer += delta
	_chase_player(delta, 0.35)
	modulate = Color(1.5, 0.5, 0)
	if state_timer >= 1.0:
		execute_ground_slam()

func _update_slam(delta: float) -> void:
	state_timer += delta
	if state_timer >= 0.5:
		modulate = Color.WHITE
		current_state = State.SLAM_RECOVER
		state_timer = 0.0

func _update_slam_recover(delta: float) -> void:
	state_timer += delta
	_chase_player(delta, 0.55)
	if state_timer >= slam_recover_duration:
		current_state = State.MOVE

func _update_projectile_prep(delta: float) -> void:
	state_timer += delta
	_chase_player(delta, 0.4)
	if state_timer >= projectile_prep_duration:
		fire_projectile_burst()
		current_state = State.PROJECTILE_RECOVER
		state_timer = 0.0

func _update_projectile_recover(delta: float) -> void:
	state_timer += delta
	_chase_player(delta, 0.55)
	if state_timer >= projectile_recover_duration:
		current_state = State.MOVE

func _update_teleport_prep(delta: float) -> void:
	state_timer += delta
	_chase_player(delta, 0.3)
	if state_timer >= teleport_prep_duration:
		execute_teleport()

func _update_teleport(delta: float) -> void:
	state_timer += delta
	if state_timer >= 0.5:
		is_invulnerable = false
		current_state = State.TELEPORT_RECOVER
		state_timer = 0.0

func _update_teleport_recover(delta: float) -> void:
	state_timer += delta
	_chase_player(delta, 0.5)
	if state_timer >= teleport_recover_duration:
		current_state = State.MOVE

func start_charge():
	current_state = State.CHARGE_PREP
	state_timer = 0.0
	charge_direction = global_position.direction_to(player.global_position)
	_play_attack_telegraph(AttackType.CHARGE)
	anim.play("charge_prep")

func start_charge_attack():
	current_state = State.CHARGE
	state_timer = 0.0
	anim.play("charge")

func spawn_minions():
	if not is_instance_valid(player):
		return

	_play_attack_telegraph(AttackType.MINION)
	var phase = _get_phase()
	var spawn_count = 3
	if phase == Phase.THREE:
		spawn_count += randi_range(0, 1)
	if phase == Phase.FOUR:
		spawn_count += randi_range(1, 2)
	for i in range(spawn_count):
		var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		var spawn_pos = global_position + offset
		if weak_enemy_scene:
			var minion = weak_enemy_scene.instantiate()
			minion.global_position = spawn_pos
			get_parent().add_child(minion)

func fire_projectile_burst():
	if not is_instance_valid(player):
		return
	if not is_instance_valid(projectile_pool):
		projectile_pool = get_tree().get_first_node_in_group("projectile_pool")
		if not is_instance_valid(projectile_pool):
			return

	var phase = _get_phase()
	var bullet_count = 12 + _get_projectile_bonus(phase)
	for i in range(bullet_count):
		var angle = (PI * 2 / bullet_count) * i
		var direction = Vector2(cos(angle), sin(angle))
		var bullet = projectile_pool.get_projectile("ice_spear")
		bullet.global_position = global_position
		bullet.target = global_position + direction * 100
		bullet.level = 1
		bullet.damage = 10
		if bullet.has_method("on_spawn"):
			bullet.on_spawn()

func start_ground_slam():
	current_state = State.SLAM_PREP
	state_timer = 0.0
	_play_attack_telegraph(AttackType.SLAM)

func execute_ground_slam():
	current_state = State.SLAM
	state_timer = 0.0
	
	var slam_areas = get_tree().get_nodes_in_group("slam_area")
	for area in slam_areas:
		area.queue_free()
	
	var slam_area = Area2D.new()
	slam_area.name = "SlamArea"
	slam_area.add_to_group("slam_area")
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 100
	collision.shape = shape
	slam_area.add_child(collision)
	slam_area.global_position = global_position
	get_parent().add_child(slam_area)
	
	slam_area.connect("area_entered", _on_slam_area_hit)
	slam_area.connect("body_entered", _on_slam_body_hit)
	
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(slam_area):
		slam_area.queue_free()

func _on_slam_area_hit(area):
	if area.is_in_group("player"):
		area.get_parent()._on_hurt_box_hurt(20, Vector2.ZERO, 0)

func _on_slam_body_hit(body):
	if body.is_in_group("player"):
		body._on_hurt_box_hurt(20, Vector2.ZERO, 0)

func start_teleport():
	if not is_instance_valid(player):
		return

	current_state = State.TELEPORT_PREP
	state_timer = 0.0
	_play_attack_telegraph(AttackType.TELEPORT)

func execute_teleport():
	current_state = State.TELEPORT
	state_timer = 0.0
	is_invulnerable = true

	var to_player = player.global_position - global_position
	var behind_player = player.global_position + to_player.normalized() * 150

	global_position = behind_player

	var teleport_effect = death_anim.instantiate()
	teleport_effect.global_position = global_position
	get_parent().add_child(teleport_effect)

func death():
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	emit_signal("remove_from_array", self)
	emit_signal("boss_defeated")
	
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	
	remove_from_group("boss")
	queue_free()

func return_to_pool():
	remove_from_group("boss")
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	if current_state == State.DEAD or is_invulnerable:
		return

	hp -= damage
	knockback = angle * knockback_amount
	if not is_enraged and hp <= max_hp * 0.5:
		is_enraged = true

	_apply_hit_stop(hit_stop_duration)
	hurt_flash_timer = 0.1
	_play_hit_vfx()

	if hp <= 0:
		death()

func reset_state():
	current_state = State.SPAWN
	state_timer = 0.0
	pattern_step_timer = 0.0
	minion_timer = 0.0
	projectile_timer = 0.0
	slam_timer = 0.0
	teleport_timer = 0.0
	hp = max_hp
	knockback = Vector2.ZERO
	is_invulnerable = false
	is_enraged = false
	pattern_index = 0
	attack_cooldowns = _build_attack_cooldowns()
	current_move_animation = ""
	last_attack_type = -1
	last_attack_repeats = 0
	sprite.speed_scale = 1.0
	anim.speed_scale = 1.0
	hit_stop_timer = 0.0
	hurt_flash_timer = 0.0
	telegraph_tint_timer = 0.0
	telegraph_tint_color = Color.WHITE
	hit_vfx_timer = 0.0

func _apply_hit_stop(duration: float) -> void:
	hit_stop_timer = max(hit_stop_timer, duration)
	sprite.speed_scale = 0.0
	anim.speed_scale = 0.0

func _play_move_animation(animation_name: String) -> void:
	if current_move_animation == animation_name:
		return
	current_move_animation = animation_name
	sprite.play(animation_name)

func _chase_player(delta: float, speed_scale: float) -> void:
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed * speed_scale
	velocity += knockback
	move_and_slide()

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			_play_move_animation("move_right")
		else:
			_play_move_animation("move_left")
	else:
		if direction.y > 0:
			_play_move_animation("move_down")
		else:
			_play_move_animation("move_up")

func _play_hit_vfx() -> void:
	if hit_vfx_timer > 0.0:
		return
	hit_vfx_timer = hit_vfx_cooldown

	var punch = create_tween()
	punch.tween_property(sprite, "scale", Vector2(1.12, 1.12), 0.05)
	punch.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

	var hit_fx = death_anim.instantiate()
	hit_fx.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
	hit_fx.scale = Vector2(0.35, 0.35)
	if hit_fx.has_node("snd_explosion"):
		hit_fx.get_node("snd_explosion").volume_db = -80.0
	get_parent().add_child(hit_fx)

func _build_attack_cooldowns() -> Dictionary:
	return {
		AttackType.CHARGE: 0.0,
		AttackType.PROJECTILE: 0.0,
		AttackType.SLAM: 0.0,
		AttackType.TELEPORT: 0.0,
		AttackType.MINION: 0.0
	}

func _tick_attack_cooldowns(delta: float) -> void:
	for key in attack_cooldowns.keys():
		attack_cooldowns[key] = max(0.0, attack_cooldowns[key] - delta)

func _get_phase() -> Phase:
	if max_hp <= 0:
		return Phase.ONE
	var ratio = float(hp) / float(max_hp)
	if ratio > 0.75:
		return Phase.ONE
	if ratio > 0.5:
		return Phase.TWO
	if ratio > 0.25:
		return Phase.THREE
	return Phase.FOUR

func _get_phase_speed_multiplier(phase: Phase) -> float:
	match phase:
		Phase.ONE:
			return 1.0
		Phase.TWO:
			return 1.1
		Phase.THREE:
			return 1.2
		Phase.FOUR:
			return 1.3
	return 1.0

func _get_attack_pattern(phase: Phase) -> Array:
	match phase:
		Phase.ONE:
			return [AttackType.CHARGE, AttackType.PROJECTILE]
		Phase.TWO:
			return [AttackType.CHARGE, AttackType.MINION]
		Phase.THREE:
			return [AttackType.SLAM, AttackType.PROJECTILE]
		Phase.FOUR:
			return [AttackType.CHARGE, AttackType.SLAM]
	return [AttackType.CHARGE, AttackType.PROJECTILE]

func _get_random_pool(phase: Phase) -> Array:
	match phase:
		Phase.ONE:
			return [AttackType.PROJECTILE, AttackType.MINION]
		Phase.TWO:
			return [AttackType.PROJECTILE, AttackType.SLAM]
		Phase.THREE:
			return [AttackType.CHARGE, AttackType.TELEPORT]
		Phase.FOUR:
			return [AttackType.PROJECTILE, AttackType.TELEPORT]
	return [AttackType.PROJECTILE, AttackType.MINION]

func _get_projectile_bonus(phase: Phase) -> int:
	match phase:
		Phase.THREE:
			return randi_range(0, 2)
		Phase.FOUR:
			return randi_range(2, 4)
	return 0

func _get_attack_base_cooldown(attack_type: int) -> float:
	match attack_type:
		AttackType.CHARGE:
			return charge_interval
		AttackType.PROJECTILE:
			return projectile_interval
		AttackType.SLAM:
			return slam_interval
		AttackType.TELEPORT:
			return teleport_interval
		AttackType.MINION:
			return minion_spawn_interval
	return 0.0

func _is_attack_available(attack_type: int) -> bool:
	return attack_cooldowns.get(attack_type, 0.0) <= 0.0

func _set_attack_cooldown(attack_type: int) -> void:
	attack_cooldowns[attack_type] = _get_attack_base_cooldown(attack_type) + cooldown_tax

func _get_next_attack(phase: Phase, distance_to_player: float) -> int:
	var weights = _build_attack_weights(phase, distance_to_player)
	var total_weight = 0.0
	for attack_type in weights.keys():
		if _is_attack_available(attack_type):
			total_weight += weights[attack_type]

	if total_weight <= 0.0:
		return -1

	var roll = randf() * total_weight
	for attack_type in weights.keys():
		if not _is_attack_available(attack_type):
			continue
		roll -= weights[attack_type]
		if roll <= 0.0:
			pattern_index += 1
			return attack_type

	return -1

func _build_attack_weights(phase: Phase, distance_to_player: float) -> Dictionary:
	var weights = {
		AttackType.CHARGE: 1.0,
		AttackType.PROJECTILE: 1.0,
		AttackType.SLAM: 1.0,
		AttackType.TELEPORT: 1.0,
		AttackType.MINION: 1.0
	}

	if distance_to_player > 260.0:
		weights[AttackType.CHARGE] += 4.0
		weights[AttackType.PROJECTILE] += 1.0
		weights[AttackType.TELEPORT] += 1.0
	elif distance_to_player > 140.0:
		weights[AttackType.PROJECTILE] += 4.0
		weights[AttackType.CHARGE] += 2.0
		weights[AttackType.MINION] += 1.5
	else:
		weights[AttackType.SLAM] += 4.5
		weights[AttackType.TELEPORT] += 2.5
		weights[AttackType.MINION] += 1.0

	match phase:
		Phase.ONE:
			weights[AttackType.PROJECTILE] += 1.0
		Phase.TWO:
			weights[AttackType.MINION] += 2.5
			weights[AttackType.PROJECTILE] += 0.5
		Phase.THREE:
			weights[AttackType.SLAM] += 2.5
			weights[AttackType.TELEPORT] += 1.5
		Phase.FOUR:
			weights[AttackType.CHARGE] += 1.5
			weights[AttackType.SLAM] += 2.0
			weights[AttackType.TELEPORT] += 2.5

	if last_attack_type != -1:
		weights[last_attack_type] *= 0.35
		if last_attack_repeats >= 1:
			weights[last_attack_type] = 0.0

	return weights

func _start_attack(attack_type: int, phase: Phase) -> void:
	if attack_type == last_attack_type:
		last_attack_repeats += 1
	else:
		last_attack_type = attack_type
		last_attack_repeats = 0
	match attack_type:
		AttackType.CHARGE:
			start_charge()
			_set_attack_cooldown(attack_type)
		AttackType.PROJECTILE:
			start_projectile_burst()
			_set_attack_cooldown(attack_type)
		AttackType.SLAM:
			start_ground_slam()
			_set_attack_cooldown(attack_type)
		AttackType.TELEPORT:
			start_teleport()
			_set_attack_cooldown(attack_type)
		AttackType.MINION:
			spawn_minions()
			_set_attack_cooldown(attack_type)

func start_projectile_burst():
	current_state = State.PROJECTILE_PREP
	state_timer = 0.0
	_play_attack_telegraph(AttackType.PROJECTILE)

func _play_attack_telegraph(attack_type: int) -> void:
	var telegraph_duration = 0.4
	var pitch = 1.0
	match attack_type:
		AttackType.CHARGE:
			telegraph_tint_color = Color(1.4, 0.6, 0.2)
			telegraph_duration = 0.5
			pitch = 0.95
			if is_instance_valid(player):
				player.screen_shake(0.1, 1.8)
		AttackType.PROJECTILE:
			telegraph_tint_color = Color(0.6, 0.9, 1.4)
			telegraph_duration = 0.4
			pitch = 1.15
		AttackType.SLAM:
			telegraph_tint_color = Color(1.6, 0.5, 0.3)
			telegraph_duration = 0.6
			pitch = 0.8
			if is_instance_valid(player):
				player.screen_shake(0.15, 2.4)
		AttackType.TELEPORT:
			telegraph_tint_color = Color(1.1, 0.5, 1.3)
			telegraph_duration = 0.4
			pitch = 1.25
		AttackType.MINION:
			telegraph_tint_color = Color(0.7, 1.2, 0.6)
			telegraph_duration = 0.4
			pitch = 1.0

	telegraph_tint_timer = telegraph_duration
	if is_instance_valid(snd_telegraph):
		snd_telegraph.stop()
		snd_telegraph.pitch_scale = pitch
		snd_telegraph.play()
