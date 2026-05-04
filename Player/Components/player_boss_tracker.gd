extends Node

@onready var player = get_parent()

func check_for_boss() -> void:
	var bosses = get_tree().get_nodes_in_group("boss")
	if bosses.size() > 0:
		player.boss_alive = true
		bosses[0].connect("boss_defeated", _on_boss_defeated)

func _on_boss_defeated() -> void:
	player.boss_alive = false
	player.boss_defeated = true
	player.win_game()
