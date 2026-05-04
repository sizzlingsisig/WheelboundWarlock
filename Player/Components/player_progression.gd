extends Node

@onready var player = get_parent()

func tick_regen(delta: float) -> void:
	if player.hp_regen > 0 and player.hp < player.maxhp:
		player.hp = min(player.hp + player.hp_regen * delta, player.maxhp)
		player.healthBar.value = player.hp

func calculate_experience(gem_exp: int) -> void:
	var exp_required: int = calculate_experiencecap()
	player.collected_experience += gem_exp
	if player.experience + player.collected_experience >= exp_required:
		player.collected_experience -= exp_required - player.experience
		player.experience_level += 1
		player.experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else:
		player.experience += player.collected_experience
		player.collected_experience = 0

	player.ui_component.set_expbar(player.experience, exp_required)

func calculate_experiencecap() -> int:
	var exp_cap: int = player.experience_level
	if player.experience_level < 20:
		exp_cap = player.experience_level * 5
	elif player.experience_level < 40:
		exp_cap = 95 + (player.experience_level - 19) * 8
	else:
		exp_cap = 255 + (player.experience_level - 39) * 12
	return exp_cap

func levelup() -> void:
	player.sndLevelUp.play()
	player.lblLevel.text = str("Level: ", player.experience_level)
	var tween = player.levelPanel.create_tween()
	tween.tween_property(player.levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	player.levelPanel.visible = true
	var options: int = 0
	var optionsmax: int = 3
	while options < optionsmax:
		var option_choice = player.itemOptions.instantiate()
		option_choice.item = get_random_item()
		player.upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true
	GameState.set_state(GameState.State.UPGRADE)

func upgrade_character(upgrade: String) -> void:
	match upgrade:
		"icespear1":
			player.icespear_level = 1
			player.icespear_baseammo += 1
		"icespear2":
			player.icespear_level = 2
			player.icespear_baseammo += 1
		"icespear3":
			player.icespear_level = 3
		"icespear4":
			player.icespear_level = 4
			player.icespear_baseammo += 2
		"tornado1":
			player.tornado_level = 1
			player.tornado_baseammo += 1
		"tornado2":
			player.tornado_level = 2
			player.tornado_baseammo += 1
		"tornado3":
			player.tornado_level = 3
			player.tornado_attackspeed -= 0.5
		"tornado4":
			player.tornado_level = 4
			player.tornado_baseammo += 1
		"javelin1":
			player.javelin_level = 1
			player.javelin_ammo = 1
		"javelin2":
			player.javelin_level = 2
		"javelin3":
			player.javelin_level = 3
		"javelin4":
			player.javelin_level = 4
		"lightning1":
			player.lightning_level = 1
			player.lightning_baseammo += 1
		"lightning2":
			player.lightning_level = 2
		"lightning3":
			player.lightning_level = 3
		"lightning4":
			player.lightning_level = 4
		"immolate1":
			player.immolate_level = 1
			player.immolate_baseammo += 1
		"immolate2":
			player.immolate_level = 2
		"immolate3":
			player.immolate_level = 3
		"immolate4":
			player.immolate_level = 4
			player.immolate_baseammo += 1
		"hollowpurple1":
			player.hollowpurple_level = 1
		"hollowpurple2":
			player.hollowpurple_level = 2
		"hollowpurple3":
			player.hollowpurple_level = 3
		"hollowpurple4":
			player.hollowpurple_level = 4
		"willowhisp1":
			player.willowhisp_level = 1
			player.willowhisp_orb_count = 1
			player.willowhisp_hit_cooldown = 0.8
		"willowhisp2":
			player.willowhisp_level = 2
			player.willowhisp_hit_cooldown = 0.6
		"willowhisp3":
			player.willowhisp_level = 3
			player.willowhisp_orb_count = 2
		"willowhisp4":
			player.willowhisp_level = 4
			player.willowhisp_orb_count = 3
			player.willowhisp_hit_cooldown = 0.5
		"armor1","armor2","armor3","armor4":
			player.armor += 1
		"speed1","speed2","speed3","speed4":
			player.movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			player.spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			player.spell_cooldown += 0.05
		"ring1","ring2":
			player.additional_attacks += 1
		"magnet1","magnet2","magnet3":
			player.magnet_radius += 25
		"magnet4":
			player.magnet_radius += 50
		"heart troll1":
			player.hp_regen += 0.5
		"heart troll2":
			player.hp_regen += 0.5
		"heart troll3":
			player.hp_regen += 1.0
		"heart troll4":
			player.hp_regen += 1.5
		"food":
			player.hp += 20
			player.hp = clamp(player.hp, 0, player.maxhp)
	player.ui_component.adjust_gui_collection(upgrade)
	player.attack()
	var option_children = player.upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	player.upgrade_options.clear()
	player.collected_upgrades.append(upgrade)
	player.levelPanel.visible = false
	player.levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	GameState.set_state(GameState.State.PLAYING)
	calculate_experience(0)

func get_random_item() -> String:
	var dblist: Array = []
	for i in UpgradeDb.get_upgrade_ids():
		var upgrade_data = UpgradeDb.get_upgrade_data(i)
		if upgrade_data.is_empty():
			continue
		if i in player.collected_upgrades:
			pass
		elif i in player.upgrade_options:
			pass
		elif upgrade_data["type"] == "item":
			pass
		elif upgrade_data["prerequisite"].size() > 0:
			var to_add: bool = true
			for n in upgrade_data["prerequisite"]:
				if not n in player.collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		player.upgrade_options.append(randomitem)
		return randomitem
	return ""

func change_time(argtime: int = 0) -> void:
	player.time = argtime
	var get_m = int(player.time / 60.0)
	var get_s = player.time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	player.lblTimer.text = str(get_m, ":", get_s)
