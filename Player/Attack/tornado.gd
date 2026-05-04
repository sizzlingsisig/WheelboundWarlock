extends Area2D

var level: int = 1
var hp: int = 9999
var speed: float = 100.0
var damage: float = 5.0
var attack_size: float = 1.0
var knockback_amount: float = 100.0
@export var lifetime: float = 2.5
@export var max_travel_distance: float = 2500.0

var last_movement: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var angle_less: Vector2 = Vector2.ZERO
var angle_more: Vector2 = Vector2.ZERO
var spawn_position: Vector2 = Vector2.ZERO

signal remove_from_array(object: Node)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	pass

func on_spawn() -> void:
	spawn_position = global_position
	var spell_size = 0.0
	if player != null:
		spell_size = player.spell_size
	var level_data = UpgradeDb.get_weapon_level_data("tornado", level)
	if level_data != null:
		hp = level_data.hp
		speed = level_data.speed
		damage = level_data.damage
		knockback_amount = level_data.knockback_amount
		var base_size = level_data.attack_size if level_data.attack_size > 0.0 else 1.0
		attack_size = base_size * (1 + spell_size)
	else:
		match level:
			1:
				hp = 9999
				speed = 100.0
				damage = 5.0
				knockback_amount = 100.0
				attack_size = 1.0 * (1 + spell_size)
			2:
				hp = 9999
				speed = 100.0
				damage = 5.0
				knockback_amount = 100.0
				attack_size = 1.0 * (1 + spell_size)
			3:
				hp = 9999
				speed = 100.0
				damage = 5.0
				knockback_amount = 100.0
				attack_size = 1.0 * (1 + spell_size)
			4:
				hp = 9999
				speed = 100.0
				damage = 5.0
				knockback_amount = 125.0
				attack_size = 1.0 * (1 + spell_size)

	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1, -0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500

	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)

	var initital_tween = create_tween().set_parallel(true)
	initital_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed
	speed = speed / 5.0
	initital_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initital_tween.play()

	var tween = create_tween()
	var set_angle = randi_range(0, 1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
	tween.play()

	var timer = get_node_or_null("Timer")
	if timer:
		timer.stop()
		timer.wait_time = max(0.05, lifetime)
		timer.start()

func _physics_process(delta: float) -> void:
	if spawn_position != Vector2.ZERO and max_travel_distance > 0.0:
		if global_position.distance_to(spawn_position) > max_travel_distance:
			emit_signal("remove_from_array", self)
			_return_to_pool()
			return
	position += angle * speed * delta

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	_return_to_pool()

func reset_state() -> void:
	level = 1
	hp = 9999
	speed = 100.0
	damage = 5.0
	attack_size = 1.0
	knockback_amount = 100.0
	last_movement = Vector2.ZERO
	angle = Vector2.ZERO
	spawn_position = Vector2.ZERO
	scale = Vector2.ONE
	position = Vector2(-1000, -1000)
	var timer = get_node_or_null("Timer")
	if timer:
		timer.stop()

func on_despawn() -> void:
	var timer = get_node_or_null("Timer")
	if timer:
		timer.stop()

func _return_to_pool() -> void:
	var pool = get_tree().get_first_node_in_group("projectile_pool")
	if pool:
		pool.return_projectile("tornado", self)
	else:
		queue_free()