extends Node2D

var enemy_pool: Dictionary = {}
var pool_max_size: int = 20

@export var spawns: Array[Spawn_info] = []
@export var boss_scene: PackedScene

@onready var player: Node = get_tree().get_first_node_in_group("player")

@export var time: int = 0
var boss_spawned: bool = false

signal changetime(time)

func _ready() -> void:
	connect("changetime", Callable(player, "change_time"))
	add_to_group("enemy_spawner")
	spawn_boss()
	boss_spawned = true

func _on_timer_timeout() -> void:
	time += 1
	var enemy_spawns: Array = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var counter: int = 0
				while counter < i.enemy_num:
					var spawn_pos: Vector2 = get_random_position()
					var new_enemy = _spawn_from_pool(i.enemy, spawn_pos)
					counter += 1
	
	if time == 300 and not boss_spawned and boss_scene != null:
		spawn_boss()
		boss_spawned = true
	
	emit_signal("changetime", time)

func spawn_boss() -> void:
	if boss_scene == null:
		return
	var boss = boss_scene.instantiate()
	boss.global_position = get_random_position()
	add_child(boss)

func _spawn_from_pool(spawn_info_res: Resource, start_pos: Vector2) -> Node:
	var res_path: String = spawn_info_res.resource_path
	if not enemy_pool.has(res_path):
		enemy_pool[res_path] = []
	
	var pool: Array = enemy_pool[res_path]
	
	if pool.size() > 0:
		var enemy = pool.pop_back()
		if is_instance_valid(enemy):
			enemy.global_position = start_pos
			enemy.hp = enemy.max_hp
			enemy.visible = true
			if enemy.has_method("reset_state"):
				enemy.reset_state()
			return enemy
	
	var new_enemy = spawn_info_res.instantiate()
	if new_enemy != null:
		add_child(new_enemy)
		new_enemy.global_position = start_pos
	return new_enemy

func return_enemy_to_pool(enemy: Node) -> void:
	var res_path: String = enemy.scene_file_path
	if res_path.is_empty():
		enemy.queue_free()
		return
	
	if not enemy_pool.has(res_path):
		enemy_pool[res_path] = []
	
	if enemy_pool[res_path].size() < pool_max_size:
		enemy.visible = false
		enemy.global_position = Vector2(-1000, -1000)
		enemy_pool[res_path].append(enemy)
	else:
		enemy.queue_free()

func get_random_position() -> Vector2:
	var vpr: Vector2 = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left: Vector2 = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y - vpr.y / 2)
	var top_right: Vector2 = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y - vpr.y / 2)
	var bottom_left: Vector2 = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y + vpr.y / 2)
	var bottom_right: Vector2 = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y + vpr.y / 2)
	var pos_side: String = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1: Vector2 = Vector2.ZERO
	var spawn_pos2: Vector2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn: float = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn: float = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)