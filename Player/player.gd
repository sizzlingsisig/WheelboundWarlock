extends CharacterBody2D

var debug_mode: bool = false

var movement_speed: float = 40.0
var hp: float = 80
var maxhp: float = 80
@export var iframe_duration: float = 0.4
var is_invulnerable: bool = false
var last_movement: Vector2 = Vector2.UP
var time: int = 0
var boss_alive: bool = false
var boss_defeated: bool = false

var movement_target: Vector2 = Vector2.ZERO
var is_moving: bool = false
var stop_distance: float = 5.0

var experience: int = 0
var experience_level: int = 1
var collected_experience: int = 0

#Attacks
var iceSpear: PackedScene = preload("res://Player/Attack/ice_spear.tscn")
var tornado: PackedScene = preload("res://Player/Attack/tornado.tscn")
var javelin: PackedScene = preload("res://Player/Attack/javelin.tscn")
var lightning: PackedScene = preload("res://Player/Attack/lightning.tscn")
var immolate: PackedScene = preload("res://Player/Attack/immolate.tscn")
var hollowPurple: PackedScene = preload("res://Player/Attack/hollow_purple.tscn")
var willOWhispOrb: PackedScene = preload("res://Player/Attack/will_o_whisp_orb.tscn")

#AttackNodes
@onready var javelinBase: Node = get_node("%JavelinBase")
@onready var projectile_pool: Node = get_tree().get_first_node_in_group("projectile_pool")

#UPGRADES
var collected_upgrades: Array = []
var upgrade_options: Array = []
var armor: int = 0
var speed: float = 0.0
var magnet_radius: float = 150.0
var hp_regen: float = 0.0
var spell_cooldown: float = 0.0
var spell_size: float = 0.0
var additional_attacks: int = 0

#IceSpear
var icespear_ammo: int = 0
var icespear_baseammo: int = 0
var icespear_attackspeed: float = 1.5
var icespear_level: int = 0

#Tornado
var tornado_ammo: int = 0
var tornado_baseammo: int = 0
var tornado_attackspeed: float = 3.0
var tornado_level: int = 0

#Javelin
var javelin_ammo: int = 0
var javelin_level: int = 0

#Lightning
var lightning_ammo: int = 0
var lightning_baseammo: int = 0
var lightning_attackspeed: float = 2.0
var lightning_level: int = 0

#Immolate
var immolate_ammo: int = 0
var immolate_baseammo: int = 0
var immolate_attackspeed: float = 5.0
var immolate_level: int = 0
var immolate_active: bool = false
var immolate_speed_boost: float = 0.0
var immolate_aura: Node = null

#HollowPurple
var hollowpurple_level: int = 0
var hollowpurple_aura: Node = null

#WillOWhisps
var willowhisp_level: int = 0
var willowhisp_orb_count: int = 0
var willowhisp_hit_cooldown: float = 0.8
var willowhisp_orbs: Array = []

var icespear_cooldown: float = 0.0
var tornado_cooldown: float = 0.0
var immolate_cooldown: float = 0.0
var lightning_cooldown: float = 0.0


#Enemy Related
var enemy_close: Array = []


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var walkTimer: Timer = get_node("%walkTimer")

@onready var movement_component: Node = $Movement
@onready var targeting_component: Node = $Targeting
@onready var combat_component: Node = $Combat
@onready var progression_component: Node = $Progression
@onready var ui_component: Node = $UI
@onready var boss_component: Node = $BossTracker

#GUI
@onready var expBar: TextureProgressBar = get_node("%ExperienceBar")
@onready var lblLevel: Label = get_node("%lbl_level")
@onready var levelPanel: Control = get_node("%LevelUp")
@onready var upgradeOptions: Control = get_node("%UpgradeOptions")
@onready var itemOptions: PackedScene = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp: AudioStreamPlayer = get_node("%snd_levelup")
@onready var healthBar: TextureProgressBar = get_node("%HealthBar")
@onready var lblTimer: Label = get_node("%lblTimer")
@onready var collectedWeapons: GridContainer = get_node("%CollectedWeapons")
@onready var collectedUpgrades: GridContainer = get_node("%CollectedUpgrades")
@onready var itemContainer: PackedScene = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel: Control = get_node("%DeathPanel")
@onready var lblResult: Label = get_node("%lbl_Result")
@onready var sndVictory: AudioStreamPlayer = get_node("%snd_victory")
@onready var sndLose: AudioStreamPlayer = get_node("%snd_lose")

#Signal
signal playerdeath

func _ready():
	if debug_mode:
		icespear_level = 4
		icespear_baseammo = 2
		tornado_level = 4
		tornado_baseammo = 2
		immolate_level = 4
		immolate_baseammo = 2
		lightning_level = 4
		lightning_baseammo = 2
		javelin_level = 4
		javelin_ammo = 3
		hollowpurple_level = 4
		willowhisp_level = 4
		willowhisp_orb_count = 3
		armor = 4
		movement_speed = 120.0
		spell_size = 0.4
		spell_cooldown = 0.2
		additional_attacks = 2
		collected_upgrades = ["icespear1","icespear2","icespear3","icespear4","tornado1","tornado2","tornado3","tornado4","immolate1","immolate2","immolate3","immolate4","lightning1","lightning2","lightning3","lightning4","javelin1","javelin2","javelin3","javelin4","hollowpurple1","hollowpurple2","hollowpurple3","hollowpurple4","willowhisp1","willowhisp2","willowhisp3","willowhisp4","armor1","armor2","armor3","armor4","speed1","speed2","speed3","speed4","tome1","tome2","tome3","tome4","scroll1","scroll2","scroll3","scroll4","ring1","ring2"]
		call_deferred("_populate_debug_hud")
		ensure_hollow_purple()
		refresh_will_o_whisps()
		spawn_javelin()
		activate_immolate()
	else:
		upgrade_character("icespear1")
	set_expbar(experience, calculate_experiencecap())
	_sync_health_ui()
	_apply_camera_limits()
	GameState.set_state(GameState.State.PLAYING)
	call_deferred("_check_for_boss")

func _check_for_boss():
	boss_component.check_for_boss()

func _on_boss_defeated():
	boss_component._on_boss_defeated()

func movement() -> void:
	movement_component.process_movement()

func _input(event: InputEvent) -> void:
	if not GameState.can_move():
		return

	if event.is_action_pressed("ui_cancel"):
		$GUILayer/GUI/PauseMenu.show_pause()
		return

	movement_component.handle_input(event)
	combat_component.handle_input(event)

func cast_attack(weapon_type: String) -> void:
	combat_component.cast_attack(weapon_type)

func _physics_process(delta: float) -> void:
	combat_component.tick_cooldowns(delta)
	progression_component.tick_regen(delta)
	movement()
	# ui_component.update_health_bar_position()  # DISABLED - positioning broken

func spawn_ice_spear() -> void:
	combat_component.spawn_ice_spear()

func spawn_tornado() -> void:
	combat_component.spawn_tornado()

func trigger_javelin_attack() -> void:
	combat_component.trigger_javelin_attack()

func spawn_lightning() -> void:
	combat_component.spawn_lightning()

func activate_immolate() -> void:
	combat_component.activate_immolate()

func attack() -> void:
	combat_component.attack()

func screen_shake(duration: float, intensity: float) -> void:
	var camera = $Camera2D
	var elapsed = 0.0
	while elapsed < duration:
		camera.offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(0.02).timeout
		elapsed += 0.02
	camera.offset = Vector2.ZERO

func _sync_health_ui() -> void:
	healthBar.max_value = maxhp
	healthBar.value = hp

func _apply_camera_limits() -> void:
	var bounds_node = get_tree().get_first_node_in_group("world_bounds")
	if not is_instance_valid(bounds_node):
		return
	var shape_node = bounds_node.get_node_or_null("CollisionShape2D")
	if shape_node == null:
		return
	var shape = shape_node.shape
	if shape == null or not shape is RectangleShape2D:
		return
	var size = shape.size
	var origin = bounds_node.global_position - (size * 0.5)
	var camera = $Camera2D
	camera.limit_left = int(origin.x)
	camera.limit_top = int(origin.y)
	camera.limit_right = int(origin.x + size.x)
	camera.limit_bottom = int(origin.y + size.y)

func _on_hurt_box_hurt(damage: float, _angle: Vector2, _knockback: float) -> void:
	if is_invulnerable:
		return
	is_invulnerable = true
	get_tree().create_timer(iframe_duration).timeout.connect(func():
		is_invulnerable = false
	)

	hp -= clamp(damage - armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	
	screen_shake(0.15, 2.0)
	
	var tween = create_tween()
	sprite.modulate = Color(2, 0.5, 0.5)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	if hp <= 0:
		death()

func spawn_javelin() -> void:
	combat_component.spawn_javelin()

func ensure_hollow_purple() -> void:
	combat_component.ensure_hollow_purple()

func _get_projectile_pool() -> Node:
	if not is_instance_valid(projectile_pool):
		projectile_pool = get_tree().get_first_node_in_group("projectile_pool")
	return projectile_pool

func refresh_will_o_whisps() -> void:
	combat_component.refresh_will_o_whisps()

func get_random_target() -> Vector2:
	return targeting_component.get_random_target()

func get_closest_target() -> Vector2:
	return targeting_component.get_closest_target()

func get_target_for_weapon(weapon_type: String) -> Vector2:
	return targeting_component.get_target_for_weapon(weapon_type)

func get_cardinal_direction_to(target_pos: Vector2) -> Vector2:
	return targeting_component.get_cardinal_direction_to(target_pos)


func _on_enemy_detection_area_body_entered(body: Node) -> void:
	targeting_component.handle_enemy_entered(body)

func _on_enemy_detection_area_body_exited(body: Node) -> void:
	targeting_component.handle_enemy_exited(body)


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp: int) -> void:
	progression_component.calculate_experience(gem_exp)

func calculate_experiencecap() -> int:
	return progression_component.calculate_experiencecap()
		
func set_expbar(set_value: int = 1, set_max_value: int = 100) -> void:
	ui_component.set_expbar(set_value, set_max_value)

func levelup() -> void:
	progression_component.levelup()

func upgrade_character(upgrade: String) -> void:
	progression_component.upgrade_character(upgrade)
	
func get_random_item() -> String:
	return progression_component.get_random_item()

func change_time(argtime: int = 0) -> void:
	progression_component.change_time(argtime)

func adjust_gui_collection(upgrade: String) -> void:
	ui_component.adjust_gui_collection(upgrade)

func _populate_debug_hud() -> void:
	ui_component.populate_debug_hud()

func death() -> void:
	ui_component.death()

func win_game() -> void:
	ui_component.win_game()


func _on_btn_menu_click_end() -> void:
	GameState.set_state(GameState.State.MENU)
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
