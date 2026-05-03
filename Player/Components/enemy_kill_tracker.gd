class_name EnemyKillTracker
extends Node

var kills_by_type: Dictionary = {}
signal threshold_reached(enemy_type: String, weapon_id: String, evolved_scene: PackedScene)

@onready var player = get_parent()

func _ready() -> void:
	player.connect("playerdeath", Callable(self, "_on_player_death"))

func register_kill(enemy_type: String) -> void:
	if not enemy_type in kills_by_type:
		kills_by_type[enemy_type] = 0
	kills_by_type[enemy_type] += 1
	_check_evolution(enemy_type)

func _check_evolution(enemy_type: String) -> void:
	var upgrades = UpgradeDb.UPGRADES
	
	for upgrade_id in upgrades:
		var upgrade = upgrades[upgrade_id]
		if not "stats" in upgrade:
			continue
		var stats = upgrade["stats"]
		if stats == null:
			continue
		if not stats is WeaponStats:
			continue
		if stats.evolution_enemy_type == enemy_type:
			var current_kills = kills_by_type.get(enemy_type, 0)
			if current_kills >= stats.evolution_kill_threshold:
				if stats.evolved_scene != null:
					emit_signal("threshold_reached", enemy_type, upgrade_id, stats.evolved_scene)

func get_kills(enemy_type: String) -> int:
	return kills_by_type.get(enemy_type, 0)

func get_all_kills() -> Dictionary:
	return kills_by_type.duplicate()

func _on_player_death() -> void:
	# Reset kills on death (optional - depends on game design)
	pass
