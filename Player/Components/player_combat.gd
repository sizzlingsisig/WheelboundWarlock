extends Node

@onready var player = get_parent()

func handle_input(event: InputEvent) -> void:
	if not GameState.can_move():
		return
	if event.is_action_pressed("attack_ice_spear"):
		cast_attack("ice_spear")
	if event.is_action_pressed("attack_tornado"):
		cast_attack("tornado")
	if event.is_action_pressed("attack_javelin"):
		cast_attack("immolate")
	if event.is_action_pressed("attack_lightning"):
		cast_attack("lightning")

func tick_cooldowns(delta: float) -> void:
	if player.icespear_cooldown > 0:
		player.icespear_cooldown -= delta
	if player.tornado_cooldown > 0:
		player.tornado_cooldown -= delta
	if player.immolate_cooldown > 0:
		player.immolate_cooldown -= delta
	if player.lightning_cooldown > 0:
		player.lightning_cooldown -= delta

func cast_attack(weapon_type: String) -> void:
	match weapon_type:
		"ice_spear":
			if player.icespear_cooldown <= 0 and player.icespear_level > 0:
				var ammo_count = player.icespear_baseammo + player.additional_attacks
				for i in range(ammo_count):
					spawn_ice_spear()
				player.icespear_cooldown = player.icespear_attackspeed * (1 - player.spell_cooldown)
		"tornado":
			if player.tornado_cooldown <= 0 and player.tornado_level > 0:
				var ammo_count = player.tornado_baseammo + player.additional_attacks
				for i in range(ammo_count):
					spawn_tornado()
				player.tornado_cooldown = player.tornado_attackspeed * (1 - player.spell_cooldown)
		"immolate":
			if player.immolate_cooldown <= 0 and player.immolate_level > 0:
				activate_immolate()
				player.immolate_cooldown = player.immolate_attackspeed * (1 - player.spell_cooldown)
		"lightning":
			if player.lightning_cooldown <= 0 and player.lightning_level > 0:
				var ammo_count = player.lightning_baseammo + player.additional_attacks
				for i in range(ammo_count):
					spawn_lightning()
				player.lightning_cooldown = player.lightning_attackspeed * (1 - player.spell_cooldown)

func spawn_ice_spear() -> void:
	var target_pos: Vector2 = player.get_target_for_weapon("ice_spear")
	var pool = player._get_projectile_pool()
	if not pool:
		return
	var icespear_attack = pool.get_projectile("ice_spear")
	icespear_attack.position = player.position
	icespear_attack.target = target_pos
	icespear_attack.level = player.icespear_level
	if icespear_attack.has_method("on_spawn"):
		icespear_attack.on_spawn()

func spawn_tornado() -> void:
	var pool = player._get_projectile_pool()
	if not pool:
		return
	var tornado_attack = pool.get_projectile("tornado")
	tornado_attack.position = player.position
	var target_pos: Vector2 = player.get_target_for_weapon("tornado")
	if target_pos != Vector2.UP:
		tornado_attack.last_movement = player.get_cardinal_direction_to(target_pos)
	else:
		tornado_attack.last_movement = player.last_movement
	tornado_attack.level = player.tornado_level
	if tornado_attack.has_method("on_spawn"):
		tornado_attack.on_spawn()

func trigger_javelin_attack() -> void:
	if player.javelinBase.get_child_count() > 0:
		player.javelinBase.get_children()[0].add_paths()

func spawn_lightning() -> void:
	var target: Vector2 = player.get_target_for_weapon("lightning")
	if target != Vector2.UP:
		var pool = player._get_projectile_pool()
		if not pool:
			return
		var lightning_attack = pool.get_projectile("lightning")
		lightning_attack.position = target
		lightning_attack.level = player.lightning_level
		if lightning_attack.has_method("on_spawn"):
			lightning_attack.on_spawn()

func activate_immolate() -> void:
	if player.immolate_active:
		player.movement_speed -= player.immolate_speed_boost

	if is_instance_valid(player.immolate_aura):
		player.immolate_aura.queue_free()

	var pool = player._get_projectile_pool()
	if not pool:
		return
	var immolate_attack = pool.get_projectile("immolate")
	immolate_attack.position = player.global_position
	immolate_attack.level = player.immolate_level
	if immolate_attack.has_method("on_spawn"):
		immolate_attack.on_spawn()
	player.immolate_aura = immolate_attack
	player.immolate_active = true

	match player.immolate_level:
		1:
			player.immolate_speed_boost = 20.0
		2:
			player.immolate_speed_boost = 35.0
		3:
			player.immolate_speed_boost = 50.0
		4:
			player.immolate_speed_boost = 70.0

	player.movement_speed += player.immolate_speed_boost

func spawn_javelin() -> void:
	var get_javelin_total: int = player.javelinBase.get_child_count()
	var calc_spawns: int = (player.javelin_ammo + player.additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = player.javelin.instantiate()
		javelin_spawn.global_position = player.global_position
		player.javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	var get_javelins = player.javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()

func ensure_hollow_purple() -> void:
	if player.hollowpurple_level <= 0:
		return
	if not is_instance_valid(player.hollowpurple_aura):
		var pool = player._get_projectile_pool()
		if not pool:
			return
		player.hollowpurple_aura = pool.get_projectile("hollow_purple")
		player.hollowpurple_aura.position = Vector2.ZERO
		if player.hollowpurple_aura.has_method("on_spawn"):
			player.hollowpurple_aura.on_spawn()
	if player.hollowpurple_aura.has_method("update_hollow_purple"):
		player.hollowpurple_aura.update_hollow_purple(player.hollowpurple_level)

func refresh_will_o_whisps() -> void:
	if player.willowhisp_level <= 0:
		return
	var valid_orbs: Array = []
	for orb in player.willowhisp_orbs:
		if is_instance_valid(orb):
			valid_orbs.append(orb)
	player.willowhisp_orbs = valid_orbs

	while player.willowhisp_orbs.size() < player.willowhisp_orb_count:
		var new_orb = player.willOWhispOrb.instantiate()
		player.add_child(new_orb)
		player.willowhisp_orbs.append(new_orb)

	while player.willowhisp_orbs.size() > player.willowhisp_orb_count:
		var orb_to_remove = player.willowhisp_orbs.pop_back()
		if is_instance_valid(orb_to_remove):
			orb_to_remove.queue_free()

	var total_orbs: int = player.willowhisp_orbs.size()
	for i in range(total_orbs):
		var orb = player.willowhisp_orbs[i]
		if is_instance_valid(orb) and orb.has_method("configure_orb"):
			orb.configure_orb(player, i, total_orbs, player.willowhisp_level, player.willowhisp_hit_cooldown)

func attack() -> void:
	if player.hollowpurple_level > 0:
		ensure_hollow_purple()
	if player.willowhisp_level > 0:
		refresh_will_o_whisps()
	if player.javelin_level > 0:
		spawn_javelin()
