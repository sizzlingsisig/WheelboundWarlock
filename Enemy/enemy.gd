extends CharacterBody2D

enum State { SPAWN, MOVE, DEAD }

@export var movement_speed = 20.0
@export var hp = 10
@export var max_hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
@export var enemy_damage = 1

var current_state: State = State.SPAWN
var state_timer: float = 0.0
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hitBox = $HitBox

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object)

func _ready():
	current_state = State.SPAWN
	state_timer = 0.0
	anim.play("walk")
	hitBox.damage = enemy_damage

func _physics_process(delta):
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
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()

	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func death():
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	return_to_pool()

func return_to_pool():
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.return_enemy_to_pool(self)

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	if current_state == State.DEAD:
		return

	hp -= damage
	knockback = angle * knockback_amount

	var tween = create_tween()
	sprite.modulate = Color(2, 2, 2)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	var punch = create_tween()
	punch.tween_property(sprite, "scale", sprite.scale * 1.2, 0.05)
	punch.tween_property(sprite, "scale", sprite.scale, 0.1)

	if hp <= 0:
		death()
	else:
		snd_hit.play()

func reset_state():
	current_state = State.SPAWN
	state_timer = 0.0
	hp = max_hp
	knockback = Vector2.ZERO
