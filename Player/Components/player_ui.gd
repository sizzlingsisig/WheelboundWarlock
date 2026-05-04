extends Node

@onready var player = get_parent()

func set_expbar(set_value: int = 1, set_max_value: int = 100) -> void:
	player.expBar.value = set_value
	player.expBar.max_value = set_max_value

func adjust_gui_collection(upgrade: String) -> void:
	var upgrade_data = UpgradeDb.get_upgrade_data(upgrade)
	if upgrade_data.is_empty():
		return
	var get_upgraded_displayname = upgrade_data["displayname"]
	var get_type = upgrade_data["type"]
	if get_type != "item":
		var get_collected_displaynames: Array = []
		for i in player.collected_upgrades:
			var collected_data = UpgradeDb.get_upgrade_data(i)
			if collected_data.is_empty():
				continue
			get_collected_displaynames.append(collected_data["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = player.itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					player.collectedWeapons.add_child(new_item)
				"upgrade":
					player.collectedUpgrades.add_child(new_item)

func populate_debug_hud() -> void:
	for upgrade in player.collected_upgrades:
		adjust_gui_collection(upgrade)

func death() -> void:
	player.deathPanel.visible = true
	player.emit_signal("playerdeath")
	get_tree().paused = true
	GameState.set_state(GameState.State.GAME_OVER)
	var tween = player.deathPanel.create_tween()
	tween.tween_property(player.deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	player.lblResult.text = "You Lose"
	player.sndLose.play()

func win_game() -> void:
	player.deathPanel.visible = true
	player.emit_signal("playerdeath")
	get_tree().paused = true
	GameState.set_state(GameState.State.WIN)
	var tween = player.deathPanel.create_tween()
	tween.tween_property(player.deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	player.lblResult.text = "You Win"
	player.sndVictory.play()

func update_health_bar_position() -> void:
	var bar = player.healthBar
	if bar == null:
		return
	var screen_pos = player.get_global_transform_with_canvas().origin
	var offset = Vector2(-bar.size.x * 0.5, -50)
	var target = screen_pos + offset
	var viewport_rect = player.get_viewport().get_visible_rect()
	var clamped_x = clamp(target.x, viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x - bar.size.x)
	var clamped_y = clamp(target.y, viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y - bar.size.y)
	bar.position = Vector2(clamped_x, clamped_y)
