extends CharacterBody2D
class_name Player

# --- Core Stats ---
@export_range(1, 999) var level: int = 1
@export_range(0, 999999) var experience: int = 0
@export_range(1, 9999) var max_hp: int = 100
@export_range(0, 9999) var current_hp: int = 100
@export_range(0, 9999) var max_stamina: int = 100
@export_range(0, 9999) var current_stamina: int = 100
@export_range(0, 999) var stamina_regen_rate: float = 12.0

# --- Primary Attributes ---
@export_range(0, 999) var strength: int = 10
@export_range(0, 999) var agility: int = 10
@export_range(0, 999) var intelligence: int = 10
@export_range(0, 999) var armor: int = 0
@export_range(0, 999) var magic_resistance: int = 0

# --- Combat Stats ---
@export_range(0.1, 999.0) var base_damage: float = 12.0
@export_range(0.0, 10.0) var attack_speed: float = 1.0
@export_range(0.0, 10.0) var attack_cooldown: float = 0.5
@export_range(0.0, 999.0) var attack_range: float = 40.0
@export_range(0.0, 1.0) var crit_chance: float = 0.08
@export_range(1.0, 5.0) var crit_multiplier: float = 1.5
@export_range(0.0, 1.0) var dodge_chance: float = 0.05

# --- Movement ---
@export_range(0.0, 9999.0) var walk_speed: float = 200.0
@export_range(0.0, 9999.0) var sprint_speed: float = 330.0
@export_range(0.0, 9999.0) var acceleration: float = 1200.0
@export_range(0.0, 9999.0) var friction: float = 900.0
@export_range(0.0, 9999.0) var dash_speed: float = 420.0
@export_range(0.0, 10.0) var dash_duration: float = 0.18
@export_range(0.0, 10.0) var dash_cooldown: float = 1.2
@export_range(0.0, 9999.0) var jump_force: float = 450.0
@export_range(0.0, 9999.0) var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Resource / Economy ---
@export_range(0, 999999) var gold: int = 0
@export_range(0, 999999) var souls: int = 0
@export_range(0, 999999) var potions: int = 0

# --- Equipment & Inventory ---
@export var equipped_weapon: Resource
@export var equipped_armor: Resource
@export var equipped_shield: Resource
var inventory: Dictionary = {
	"weapons": [],
	"armor": [],
	"consumables": [],
	"materials": []
}

# --- Status Flags ---
var move_velocity: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false
var is_dashing: bool = false
var is_sprinting: bool = false
var is_invulnerable: bool = false
var invulnerable_time: float = 0.0
var attack_timer: float = 0.0
var attack_duration: float = 0.15
var attack_active: bool = false
var dash_timer: float = 0.0
var stun_timer: float = 0.0
var is_dead: bool = false

@onready var base_character: BaseCharacter = $BaseCharacter

# --- Ability / Spell State ---
@export_range(0.0, 999.0) var spell_power: float = 10.0
@export_range(0.0, 999.0) var special_cooldown: float = 4.0
@export_range(0.0, 999.0) var spell_cooldown: float = 1.2
var special_timer: float = 0.0
var spell_timer: float = 0.0

# --- Helpers ---
func _ready() -> void:
	current_hp = clamp(current_hp, 0, max_hp)
	current_stamina = clamp(current_stamina, 0, max_stamina)

	if base_character:
		base_character.set_visual("kalboarmor")
		base_character.set_direction(Vector2.DOWN, false)

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	var moving = input_vector != Vector2.ZERO
	if moving:
		input_vector = input_vector.normalized()
		facing_direction = input_vector
		move_velocity = move_velocity.move_toward(input_vector * walk_speed, acceleration * delta)
	else:
		move_velocity = move_velocity.move_toward(Vector2.ZERO, friction * delta)

	if base_character:
		base_character.set_direction(facing_direction, moving)

	if Input.is_action_just_pressed("ui_accept") and attack_timer <= 0.0 and current_stamina >= 10:
		perform_attack()

	process_combat(delta)
	process_regen(delta)

	velocity = move_velocity
	move_and_slide()

func perform_attack() -> void:
	if not is_alive():
		return

	current_stamina = max(current_stamina - 10, 0)
	attack_timer = attack_cooldown
	attack_active = true

	var attack_origin = global_position + facing_direction.normalized() * (attack_range * 0.5)
	var attack_shape = CircleShape2D.new()
	attack_shape.radius = attack_range

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = attack_shape
	params.transform = Transform2D(0.0, attack_origin)
	params.collide_with_bodies = true
	params.collide_with_areas = true
	params.exclude = [self]

	for hit in get_world_2d().direct_space_state.intersect_shape(params, 8):
		var body = hit.collider
		if body and body != self and body.has_method("apply_damage"):
			body.apply_damage(base_damage)

func process_combat(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer = max(0.0, attack_timer - delta)
	if invulnerable_time > 0.0:
		invulnerable_time = max(0.0, invulnerable_time - delta)
	if attack_active and attack_timer <= attack_cooldown - attack_duration:
		attack_active = false

func process_regen(delta: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)

func is_alive() -> bool:
	return current_hp > 0

func apply_damage(amount: float) -> void:
	current_hp = max(current_hp - int(amount), 0)
	if current_hp == 0:
		_die()

func _die() -> void:
	is_dead = true
	# TODO: add death behavior and game over handling
