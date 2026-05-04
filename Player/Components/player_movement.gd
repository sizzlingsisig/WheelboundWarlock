extends Node

@onready var player = get_parent()

func handle_input(event: InputEvent) -> void:
	if not GameState.can_move():
		return
	if event.is_action_pressed("move_to_target"):
		var mouse_pos: Vector2 = player.get_global_mouse_position()
		var bounds = _get_world_bounds_rect()
		player.movement_target = _clamp_to_bounds(mouse_pos, bounds)
		player.is_moving = true

func process_movement() -> void:
	if player.is_moving:
		var direction: Vector2 = player.global_position.direction_to(player.movement_target)
		var distance: float = player.global_position.distance_to(player.movement_target)
		if distance <= player.stop_distance:
			player.is_moving = false
			player.velocity = Vector2.ZERO
		else:
			player.last_movement = direction
			if abs(direction.x) > abs(direction.y):
				player.sprite.play("move_right" if direction.x > 0 else "move_left")
			else:
				player.sprite.play("move_down" if direction.y > 0 else "move_up")
			player.velocity = direction.normalized() * player.movement_speed
	else:
		if player.last_movement.x != 0:
			player.sprite.play("idle_right" if player.last_movement.x > 0 else "idle_left")
		else:
			player.sprite.play("idle_down" if player.last_movement.y > 0 else "idle_up")
		player.velocity = Vector2.ZERO

	player.move_and_slide()
	var bounds = _get_world_bounds_rect()
	if bounds:
		player.global_position = _clamp_to_bounds(player.global_position, bounds)

func _get_world_bounds_rect() -> Rect2:
	var bounds_node = get_tree().get_first_node_in_group("world_bounds")
	if not is_instance_valid(bounds_node):
		return Rect2()
	var shape_node = bounds_node.get_node_or_null("CollisionShape2D")
	if shape_node == null:
		return Rect2()
	var shape = shape_node.shape
	if shape == null or not shape is RectangleShape2D:
		return Rect2()
	var size = shape.size
	var origin = bounds_node.global_position - (size * 0.5)
	return Rect2(origin, size)

func _clamp_to_bounds(pos: Vector2, bounds: Rect2) -> Vector2:
	if bounds.size == Vector2.ZERO:
		return pos
	var x = clamp(pos.x, bounds.position.x, bounds.position.x + bounds.size.x)
	var y = clamp(pos.y, bounds.position.y, bounds.position.y + bounds.size.y)
	return Vector2(x, y)
