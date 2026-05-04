extends CharacterBody2D

enum State { SPAWN, MOVE, DEAD }
enum AttackState {
	IDLE,
	TELEPORT_TELEGRAPH,
	TELEPORT_MOVE,
	TELEPORT_RECOVER,
	SLAM_PREP,
	SLAM_HIT,
	SLAM_RECOVER
}

@export var movement_speed: float = 30.0
@export var hp: float = 10
@export var max_hp: float = 10
@export var knockback_recovery: float = 3.5
@export var experience: int = 1
@export var enemy_damage: float = 1

@export var attack_interval: float = 5.0
@export var attack_damage: float = 10.0
@export var is_boss: bool = false

var current_state: State = State.SPAWN
var state_timer: float = 0.0
var knockback: Vector2 = Vector2.ZERO
var attack_timer: float = 0.0
var is_invulnerable: bool = false
var attack_state: AttackState = AttackState.IDLE
var attack_state_timer: float = 0.0

const TELEPORT_TELEGRAPH_DURATION: float = 0.18
const TELEPORT_RECOVER_DURATION: float = 0.25
const SLAM_PREP_DURATION: float = 0.2
const SLAM_RECOVER_DURATION: float = 0.2

@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var loot_base: Node = get_tree().get_first_node_in_group("loot")
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var snd_hit: AudioStreamPlayer2D = $snd_hit
@onready var hitBox: Area2D = $HitBox

var death_anim: PackedScene = preload("res://Enemy/explosion.tscn")
var exp_gem: PackedScene = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object: Node)
signal boss_defeated

func _ready() -> void:
	current_state = State.SPAWN
	state_timer = 0.0
	anim.play("walk")
	hitBox.damage = enemy_damage
	if is_in_group("boss"):
		is_boss = true

func _physics_process(delta: float) -> void:
	match current_state:
		State.SPAWN:
			_update_spawn(delta)
		State.MOVE:
			_update_move(delta)
		State.DEAD:
			pass

func _update_spawn(delta: float) -> void:
	state_timer += delta
	if state_timer >= 0.5:
		current_state = State.MOVE

func _update_move(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()

	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false
	
	if is_boss:
		_update_attack_fsm(delta)

func death() -> void:
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	emit_signal("remove_from_array", self)
	if is_in_group("boss"):
		emit_signal("boss_defeated")
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	return_to_pool()

func return_to_pool() -> void:
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.return_enemy_to_pool(self)

func _on_hurt_box_hurt(damage: float, angle: Vector2, knockback_amount: float) -> void:
	if current_state == State.DEAD or is_invulnerable:
		return

	hp -= damage
	knockback = angle * knockback_amount

	var tween = create_tween()
	sprite.modulate = Color(2, 2, 2)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	var punch = create_tween()
	var punch_scale = 1.05 if is_boss else 1.2
	punch.tween_property(sprite, "scale", sprite.scale * punch_scale, 0.05)
	punch.tween_property(sprite, "scale", sprite.scale, 0.1)

	if hp <= 0:
		death()
	else:
		snd_hit.play()

func reset_state() -> void:
	current_state = State.SPAWN
	state_timer = 0.0
	hp = max_hp
	knockback = Vector2.ZERO
	attack_timer = 0.0
	attack_state = AttackState.IDLE
	attack_state_timer = 0.0
	is_invulnerable = false

func _update_attack_fsm(delta: float) -> void:
	if not is_instance_valid(player):
		return
	if attack_interval > 0 and attack_state == AttackState.IDLE:
		attack_timer += delta
		if attack_timer >= attack_interval:
			attack_timer = 0.0
			_start_boss_attack()
			return

	attack_state_timer += delta
	match attack_state:
		AttackState.TELEPORT_TELEGRAPH:
			if attack_state_timer >= TELEPORT_TELEGRAPH_DURATION:
				_enter_teleport_move()
		AttackState.TELEPORT_MOVE:
			_enter_teleport_recover()
		AttackState.TELEPORT_RECOVER:
			if attack_state_timer >= TELEPORT_RECOVER_DURATION:
				_end_attack_state()
		AttackState.SLAM_PREP:
			if attack_state_timer >= SLAM_PREP_DURATION:
				_enter_slam_hit()
		AttackState.SLAM_HIT:
			_enter_slam_recover()
		AttackState.SLAM_RECOVER:
			if attack_state_timer >= SLAM_RECOVER_DURATION:
				_end_attack_state()
		_:
			pass

func _start_boss_attack() -> void:
	var distance = global_position.distance_to(player.global_position)
	if distance > 100:
		_enter_teleport_telegraph()
	else:
		_enter_slam_prep()

func _enter_teleport_telegraph() -> void:
	attack_state = AttackState.TELEPORT_TELEGRAPH
	attack_state_timer = 0.0
	is_invulnerable = true
	var telegraph = create_tween()
	telegraph.tween_property(sprite, "modulate", Color(2, 2, 2, 0.2), TELEPORT_TELEGRAPH_DURATION)
	telegraph.play()

func _enter_teleport_move() -> void:
	attack_state = AttackState.TELEPORT_MOVE
	attack_state_timer = 0.0
	if not is_instance_valid(player):
		return
	var to_player = player.global_position - global_position
	var behind_player = player.global_position + to_player.normalized() * 150
	global_position = behind_player

func _enter_teleport_recover() -> void:
	attack_state = AttackState.TELEPORT_RECOVER
	attack_state_timer = 0.0
	modulate = Color(1.5, 0.5, 1.5, 0.2)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, TELEPORT_RECOVER_DURATION)
	tween.play()
	is_invulnerable = false

func _enter_slam_prep() -> void:
	attack_state = AttackState.SLAM_PREP
	attack_state_timer = 0.0
	sprite.modulate = Color(2, 0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, SLAM_PREP_DURATION)
	tween.play()

func _enter_slam_hit() -> void:
	attack_state = AttackState.SLAM_HIT
	attack_state_timer = 0.0
	if is_instance_valid(player):
		player._on_hurt_box_hurt(attack_damage, Vector2.ZERO, 0)

func _enter_slam_recover() -> void:
	attack_state = AttackState.SLAM_RECOVER
	attack_state_timer = 0.0

func _end_attack_state() -> void:
	attack_state = AttackState.IDLE
	attack_state_timer = 0.0