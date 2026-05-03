extends CharacterBody2D

var debug_mode = false

var movement_speed = 40.0
var hp = 80
var maxhp = 80
@export var iframe_duration = 0.4
var is_invulnerable = false
var last_movement = Vector2.UP
var time = 0

var movement_target = Vector2.ZERO
var is_moving = false
var stop_distance = 5.0

var experience = 0
var experience_level = 1
var collected_experience = 0

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")
var lightning = preload("res://Player/Attack/lightning.tscn")
var immolate = preload("res://Player/Attack/immolate.tscn")
var hollowPurple = preload("res://Player/Attack/hollow_purple.tscn")
var willOWhispOrb = preload("res://Player/Attack/will_o_whisp_orb.tscn")

#AttackNodes
@onready var javelinBase = get_node("%JavelinBase")

#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var magnet_radius = 150.0
var hp_regen = 0.0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

#Javelin
var javelin_ammo = 0
var javelin_level = 0

#Lightning
var lightning_ammo = 0
var lightning_baseammo = 0
var lightning_attackspeed = 2.0
var lightning_level = 0

#Immolate
var immolate_ammo = 0
var immolate_baseammo = 0
var immolate_attackspeed = 5.0
var immolate_level = 0
var immolate_active = false
var immolate_speed_boost = 0.0
var immolate_aura = null

#HollowPurple
var hollowpurple_level = 0
var hollowpurple_aura = null

#WillOWhisps
var willowhisp_level = 0
var willowhisp_orb_count = 0
var willowhisp_hit_cooldown = 0.8
var willowhisp_orbs = []

var icespear_cooldown = 0.0
var tornado_cooldown = 0.0
var immolate_cooldown = 0.0
var lightning_cooldown = 0.0


#Enemy Related
var enemy_close = []


@onready var sprite = $AnimatedSprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

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
	_on_hurt_box_hurt(0,0,0)

func movement():
	if is_moving:
		var direction = global_position.direction_to(movement_target)
		var distance = global_position.distance_to(movement_target)
		
		if distance <= stop_distance:
			is_moving = false
			velocity = Vector2.ZERO
		else:
			last_movement = direction
			if abs(direction.x) > abs(direction.y):
				sprite.play("move_right" if direction.x > 0 else "move_left")
			else:
				sprite.play("move_down" if direction.y > 0 else "move_up")
			velocity = direction.normalized() * movement_speed
	else:
		if last_movement.x != 0:
			sprite.play("idle_right" if last_movement.x > 0 else "idle_left")
		else:
			sprite.play("idle_down" if last_movement.y > 0 else "idle_up")
		velocity = Vector2.ZERO
	
	move_and_slide()

func _input(event):
	if event.is_action_pressed("move_to_target"):
		var mouse_pos = get_global_mouse_position()
		movement_target = mouse_pos
		is_moving = true
	if event.is_action_pressed("attack_ice_spear"):
		cast_attack("ice_spear")
	if event.is_action_pressed("attack_tornado"):
		cast_attack("tornado")
	if event.is_action_pressed("attack_javelin"):
		cast_attack("immolate")
	if event.is_action_pressed("attack_lightning"):
		cast_attack("lightning")

func cast_attack(weapon_type):
	match weapon_type:
		"ice_spear":
			if icespear_cooldown <= 0 and icespear_level > 0:
				var ammo_count = icespear_baseammo + additional_attacks
				for i in range(ammo_count):
					spawn_ice_spear()
				icespear_cooldown = icespear_attackspeed * (1 - spell_cooldown)
		"tornado":
			if tornado_cooldown <= 0 and tornado_level > 0:
				var ammo_count = tornado_baseammo + additional_attacks
				for i in range(ammo_count):
					spawn_tornado()
				tornado_cooldown = tornado_attackspeed * (1 - spell_cooldown)
		"immolate":
			if immolate_cooldown <= 0 and immolate_level > 0:
				activate_immolate()
				immolate_cooldown = immolate_attackspeed * (1 - spell_cooldown)
		"lightning":
			if lightning_cooldown <= 0 and lightning_level > 0:
				var ammo_count = lightning_baseammo + additional_attacks
				for i in range(ammo_count):
					spawn_lightning()
				lightning_cooldown = lightning_attackspeed * (1 - spell_cooldown)

func _physics_process(delta):
	if icespear_cooldown > 0:
		icespear_cooldown -= delta
	if tornado_cooldown > 0:
		tornado_cooldown -= delta
	if immolate_cooldown > 0:
		immolate_cooldown -= delta
	if lightning_cooldown > 0:
		lightning_cooldown -= delta
	if hp_regen > 0 and hp < maxhp:
		hp = min(hp + hp_regen * delta, maxhp)
		healthBar.value = hp
	movement()

func spawn_ice_spear():
	var target_pos = get_random_target()
	var icespear_attack = iceSpear.instantiate()
	icespear_attack.position = position
	icespear_attack.target = target_pos
	icespear_attack.level = icespear_level
	add_child(icespear_attack)

func spawn_tornado():
	var tornado_attack = tornado.instantiate()
	tornado_attack.position = position
	tornado_attack.last_movement = last_movement
	tornado_attack.level = tornado_level
	add_child(tornado_attack)

func trigger_javelin_attack():
	if javelinBase.get_child_count() > 0:
		javelinBase.get_children()[0].add_paths()

func spawn_lightning():
	var target = get_random_target()
	if target != Vector2.UP:
		var lightning_attack = lightning.instantiate()
		lightning_attack.position = target
		lightning_attack.level = lightning_level
		add_child(lightning_attack)

func activate_immolate():
	if immolate_active and is_instance_valid(immolate_aura):
		immolate_aura.queue_free()
	
	var immolate_attack = immolate.instantiate()
	immolate_attack.position = global_position
	immolate_attack.level = immolate_level
	add_child(immolate_attack)
	immolate_aura = immolate_attack
	immolate_active = true
	
	match immolate_level:
		1:
			immolate_speed_boost = 20.0
		2:
			immolate_speed_boost = 35.0
		3:
			immolate_speed_boost = 50.0
		4:
			immolate_speed_boost = 70.0
	
	movement_speed += immolate_speed_boost

func attack():
	if hollowpurple_level > 0:
		ensure_hollow_purple()
	if willowhisp_level > 0:
		refresh_will_o_whisps()
	if javelin_level > 0:
		spawn_javelin()

func screen_shake(duration: float, intensity: float):
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

func _on_hurt_box_hurt(damage, _angle, _knockback):
	if is_invulnerable:
		return
	is_invulnerable = true
	get_tree().create_timer(iframe_duration).timeout.connect(func():
		is_invulnerable = false
	)

	hp -= clamp(damage-armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	
	screen_shake(0.15, 2.0)
	
	var tween = create_tween()
	sprite.modulate = Color(2, 0.5, 0.5)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	var punch = create_tween()
	punch.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.05)
	punch.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	if hp <= 0:
		death()

func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	#Upgrade Javelin
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()

func ensure_hollow_purple():
	if hollowpurple_level <= 0:
		return
	if not is_instance_valid(hollowpurple_aura):
		hollowpurple_aura = hollowPurple.instantiate()
		hollowpurple_aura.position = Vector2.ZERO
		add_child(hollowpurple_aura)
	if hollowpurple_aura.has_method("update_hollow_purple"):
		hollowpurple_aura.update_hollow_purple(hollowpurple_level)

func refresh_will_o_whisps():
	if willowhisp_level <= 0:
		return
	var valid_orbs = []
	for orb in willowhisp_orbs:
		if is_instance_valid(orb):
			valid_orbs.append(orb)
	willowhisp_orbs = valid_orbs
	
	while willowhisp_orbs.size() < willowhisp_orb_count:
		var new_orb = willOWhispOrb.instantiate()
		add_child(new_orb)
		willowhisp_orbs.append(new_orb)
	
	while willowhisp_orbs.size() > willowhisp_orb_count:
		var orb_to_remove = willowhisp_orbs.pop_back()
		if is_instance_valid(orb_to_remove):
			orb_to_remove.queue_free()
	
	var total_orbs = willowhisp_orbs.size()
	for i in range(total_orbs):
		var orb = willowhisp_orbs[i]
		if is_instance_valid(orb) and orb.has_method("configure_orb"):
			orb.configure_orb(self, i, total_orbs, willowhisp_level, willowhisp_hit_cooldown)

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required-experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
		
	return exp_cap
		
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"lightning1":
			lightning_level = 1
			lightning_baseammo += 1
		"lightning2":
			lightning_level = 2
		"lightning3":
			lightning_level = 3
		"lightning4":
			lightning_level = 4
		"immolate1":
			immolate_level = 1
			immolate_baseammo += 1
		"immolate2":
			immolate_level = 2
		"immolate3":
			immolate_level = 3
		"immolate4":
			immolate_level = 4
			immolate_baseammo += 1
		"hollowpurple1":
			hollowpurple_level = 1
		"hollowpurple2":
			hollowpurple_level = 2
		"hollowpurple3":
			hollowpurple_level = 3
		"hollowpurple4":
			hollowpurple_level = 4
		"willowhisp1":
			willowhisp_level = 1
			willowhisp_orb_count = 1
			willowhisp_hit_cooldown = 0.8
		"willowhisp2":
			willowhisp_level = 2
			willowhisp_hit_cooldown = 0.6
		"willowhisp3":
			willowhisp_level = 3
			willowhisp_orb_count = 2
		"willowhisp4":
			willowhisp_level = 4
			willowhisp_orb_count = 3
			willowhisp_hit_cooldown = 0.5
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"magnet1","magnet2","magnet3":
			magnet_radius += 25
		"magnet4":
			magnet_radius += 50
		"heart troll1":
			hp_regen += 0.5
		"heart troll2":
			hp_regen += 0.5
		"heart troll3":
			hp_regen += 1.0
		"heart troll4":
			hp_regen += 1.5
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)
	
func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #Find already collected upgrades
			pass
		elif i in upgrade_options: #If the upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #Don't pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #Check for PreRequisites
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime = 0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0,get_m)
	if get_s < 10:
		get_s = str(0,get_s)
	lblTimer.text = str(get_m,":",get_s)

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

func _populate_debug_hud():
	for upgrade in collected_upgrades:
		adjust_gui_collection(upgrade)

func death():
	deathPanel.visible = true
	emit_signal("playerdeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel,"position",Vector2(220,50),3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 300:
		lblResult.text = "You Win"
		sndVictory.play()
	else:
		lblResult.text = "You Lose"
		sndLose.play()


func _on_btn_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
