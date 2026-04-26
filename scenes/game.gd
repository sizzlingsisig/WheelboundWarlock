extends Node2D

@export var player_scene_path: String = "res://scenes/player.tscn"
@export var enemy_scene_path: String = "res://scenes/enemy.tscn"

var player_scene: PackedScene
var enemy_scene: PackedScene

@onready var world = $World
@onready var enemies = $Enemies
@onready var health_label = $HUD/HealthLabel
@onready var info_label = $HUD/InfoLabel

var player: Player

func _ready() -> void:
	player_scene = load(player_scene_path) as PackedScene
	enemy_scene = load(enemy_scene_path) as PackedScene

	player = player_scene.instantiate() as Player
	player.position = Vector2(380, 260)
	world.add_child(player)

	spawn_enemy(Vector2(520, 260))
	spawn_enemy(Vector2(260, 260))
	spawn_enemy(Vector2(380, 140))
	update_hud()

func spawn_enemy(spawn_position: Vector2) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_position
	enemy.target = player
	enemies.add_child(enemy)

func _process(_delta: float) -> void:
	if not player:
		return

	update_hud()

	if not player.is_alive():
		info_label.text = "Game Over · Reload the scene to try again"
		set_process(false)

func update_hud() -> void:
	if not player:
		return

	health_label.text = "HP: %d / %d" % [player.current_hp, player.max_hp]
	info_label.text = "Enemies: %d   Attack with Space" % enemies.get_child_count()
