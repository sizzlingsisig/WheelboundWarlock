extends CharacterBody2D
class_name Enemy

@export_range(1, 999) var max_hp: int = 35
@export_range(0.0, 9999.0) var speed: float = 130.0
@export_range(0.0, 9999.0) var attack_range: float = 24.0
@export_range(0.0, 9999.0) var damage: float = 10.0
@export_range(0.0, 10.0) var attack_cooldown: float = 1.4

var current_hp: int = 0
var attack_timer: float = 0.0
var target: Player

func _ready() -> void:
	current_hp = max_hp

func _physics_process(delta: float) -> void:
	if not target or not target.is_alive():
		velocity = Vector2.ZERO
		return

	var direction = target.global_position - global_position
	if direction.length() > attack_range:
		velocity = direction.normalized() * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_cooldown
			target.apply_damage(damage)

func apply_damage(amount: float) -> void:
	current_hp = max(current_hp - int(amount), 0)
	if current_hp <= 0:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color(1.0, 0.2, 0.2))
	draw_circle(Vector2.ZERO, 12.0, Color(1.0, 0.6, 0.6))
