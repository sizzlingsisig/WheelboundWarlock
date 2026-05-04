extends Area2D

var level: int = 1
var hp: int = 1
var speed: float = 100.0
var damage: float = 5.0
var knockback_amount: float = 100.0
var attack_size: float = 1.0
@export var lifetime: float = 2.5
@export var max_travel_distance: float = 2500.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var spawn_position: Vector2 = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object: Node)

func _ready() -> void:
	pass

func on_spawn() -> void:
	spawn_position = global_position
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	var spell_size = 0.0
	if player != null:
		spell_size = player.spell_size
	var level_data = UpgradeDb.get_weapon_level_data("icespear", level)
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
				hp = 1
				speed = 100.0
				damage = 5.0
				knockback_amount = 100.0
				attack_size = 1.0 * (1 + spell_size)
			2:
				hp = 1
				speed = 100.0
				damage = 5.0
				knockback_amount = 100.0
				attack_size = 1.0 * (1 + spell_size)
			3:
				hp = 2
				speed = 100.0
				damage = 8.0
				knockback_amount = 100.0
				attack_size = 1.0 * (1 + spell_size)
			4:
				hp = 2
				speed = 100.0
				damage = 8.0
				knockback_amount = 100.0
				attack_size = 1.0 * (1 + spell_size)

	var tween = create_tween()
	scale = Vector2(0.1, 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
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

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		_return_to_pool()

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	_return_to_pool()

func reset_state() -> void:
	level = 1
	hp = 1
	speed = 100.0
	damage = 5.0
	knockback_amount = 100.0
	attack_size = 1.0
	target = Vector2.ZERO
	angle = Vector2.ZERO
	spawn_position = Vector2.ZERO
	scale = Vector2(0.1, 0.1)
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
		pool.return_projectile("ice_spear", self)
	else:
		queue_free()