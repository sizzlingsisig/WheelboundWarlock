extends Node

@onready var player = get_parent()

func handle_enemy_entered(body: Node) -> void:
	if not player.enemy_close.has(body):
		player.enemy_close.append(body)

func handle_enemy_exited(body: Node) -> void:
	if player.enemy_close.has(body):
		player.enemy_close.erase(body)

func _get_valid_enemies() -> Array:
	var valid_enemies: Array = []
	for enemy in player.enemy_close:
		if not is_instance_valid(enemy):
			continue
		if enemy.is_queued_for_deletion():
			continue
		if not enemy.has_method("_on_hurt_box_hurt"):
			continue
		valid_enemies.append(enemy)
	return valid_enemies

func get_random_target() -> Vector2:
	var valid_enemies = _get_valid_enemies()
	if valid_enemies.size() > 0:
		return valid_enemies.pick_random().global_position
	return Vector2.UP

func get_closest_target() -> Vector2:
	var valid_enemies = _get_valid_enemies()
	if valid_enemies.is_empty():
		return Vector2.UP
	var closest_enemy = valid_enemies[0]
	var closest_distance = player.global_position.distance_to(closest_enemy.global_position)
	for enemy in valid_enemies:
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy.global_position

func get_target_for_weapon(weapon_type: String) -> Vector2:
	match weapon_type:
		"javelin", "lightning", "ice_spear":
			return get_closest_target()
		"tornado":
			return get_random_target()
		_:
			return get_random_target()

func get_cardinal_direction_to(target_pos: Vector2) -> Vector2:
	var direction = player.global_position.direction_to(target_pos)
	if abs(direction.x) >= abs(direction.y):
		return Vector2.RIGHT if direction.x >= 0.0 else Vector2.LEFT
	return Vector2.DOWN if direction.y >= 0.0 else Vector2.UP
