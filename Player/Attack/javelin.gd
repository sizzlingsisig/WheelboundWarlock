extends Area2D

var level = 1
var hp = 9999
var speed = 200.0
var damage = 10
var knockback_amount = 100
var paths = 1
var attack_size = 1.0
var attack_speed = 5.0

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var spr_jav_reg = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_atk = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirectionTimer = get_node("%ChangeDirection")
@onready var resetPosTimer = get_node ("%ResetPosTimer")
@onready var snd_attack = $snd_attack

signal remove_from_array(object)

func _ready():
	update_javelin()
	_on_reset_pos_timer_timeout()

func update_javelin():
	level = player.javelin_level
	var spell_size = 0.0
	var spell_cooldown = 0.0
	if player != null:
		spell_size = player.spell_size
		spell_cooldown = player.spell_cooldown
	var level_data = UpgradeDb.get_weapon_level_data("javelin", level)
	if level_data != null:
		hp = level_data.hp
		speed = level_data.speed
		damage = level_data.damage
		knockback_amount = level_data.knockback_amount
		paths = level_data.paths
		var base_size = level_data.attack_size if level_data.attack_size > 0.0 else 1.0
		attack_size = base_size * (1 + spell_size)
		var base_speed = level_data.attack_speed if level_data.attack_speed > 0.0 else 5.0
		attack_speed = base_speed * (1 - spell_cooldown)
	else:
		match level:
			1:
				hp = 9999
				speed = 200.0
				damage = 10
				knockback_amount = 100
				paths = 1
				attack_size = 1.0 * (1 + spell_size)
				attack_speed = 5.0 * (1-spell_cooldown)
			2:
				hp = 9999
				speed = 200.0
				damage = 10
				knockback_amount = 100
				paths = 2
				attack_size = 1.0 * (1 + spell_size)
				attack_speed = 5.0 * (1-spell_cooldown)
			3:
				hp = 9999
				speed = 200.0
				damage = 10
				knockback_amount = 100
				paths = 3
				attack_size = 1.0 * (1 + spell_size)
				attack_speed = 5.0 * (1-spell_cooldown)
			4:
				hp = 9999
				speed = 200.0
				damage = 15
				knockback_amount = 120
				paths = 3
				attack_size = 1.0 * (1 + spell_size)
				attack_speed = 5.0 * (1-spell_cooldown)
			
	
	scale = Vector2(1.0,1.0) * attack_size
	attackTimer.wait_time = attack_speed

func _physics_process(delta):
	if target_array.size() > 0:
		position += angle*speed*delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_dif = global_position - player.global_position
		var return_speed = 20
		if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500:
			return_speed = 100
		position += player_angle*return_speed*delta
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)

func add_paths():
	snd_attack.play()
	emit_signal("remove_from_array",self)
	target_array = _get_closest_targets(paths)
	if target_array.is_empty():
		target_array.append(player.get_random_target())
	enable_attack(true)
	target = target_array[0]
	process_path()

func _get_closest_targets(max_count: int) -> Array:
	var results: Array = []
	if player == null:
		return results
	var candidates = []
	for enemy in player.enemy_close:
		if not is_instance_valid(enemy):
			continue
		if enemy.is_queued_for_deletion():
			continue
		if not enemy.has_method("_on_hurt_box_hurt"):
			continue
		var distance = global_position.distance_to(enemy.global_position)
		candidates.append({
			"enemy": enemy,
			"distance": distance
		})
	if candidates.is_empty():
		return results
	candidates.sort_custom(func(a, b): return a["distance"] < b["distance"])
	for entry in candidates:
		results.append(entry["enemy"].global_position)
		if results.size() >= max_count:
			break
	return results

func process_path():
	angle = global_position.direction_to(target)
	changeDirectionTimer.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle() + deg_to_rad(135)
	tween.tween_property(self,"rotation",new_rotation_degrees,0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enable_attack(atk = true):
	if atk:
		collision.call_deferred("set","disabled",false)
		sprite.texture = spr_jav_atk
	else:
		collision.call_deferred("set","disabled",true)
		sprite.texture = spr_jav_reg

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			snd_attack.play()
			emit_signal("remove_from_array",self)
		else:
			changeDirectionTimer.stop()
			attackTimer.start()
			enable_attack(false)
	else:
		changeDirectionTimer.stop()
		attackTimer.start()
		enable_attack(false)


func _on_reset_pos_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50

func reset_state() -> void:
	level = 1
	hp = 9999
	speed = 200.0
	damage = 10
	knockback_amount = 100
	paths = 1
	attack_size = 1.0
	attack_speed = 5.0
	target = Vector2.ZERO
	target_array = []
	angle = Vector2.ZERO
	reset_pos = Vector2.ZERO
	scale = Vector2.ONE
	position = Vector2(-1000, -1000)

func _return_to_pool() -> void:
	var pool = get_tree().get_first_node_in_group("projectile_pool")
	if pool:
		pool.return_projectile("javelin", self)
	else:
		queue_free()
