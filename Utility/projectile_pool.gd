extends Node

var pools: Dictionary = {}

@export var pool_size_per_type: int = 30

var projectile_scenes: Dictionary = {
	"ice_spear": preload("res://Player/Attack/ice_spear.tscn"),
	"tornado": preload("res://Player/Attack/tornado.tscn"),
	"lightning": preload("res://Player/Attack/lightning.tscn"),
	"javelin": preload("res://Player/Attack/javelin.tscn"),
	"immolate": preload("res://Player/Attack/immolate.tscn"),
	"hollow_purple": preload("res://Player/Attack/hollow_purple.tscn"),
}

func _ready() -> void:
	for key in projectile_scenes:
		_initialize_pool(key, projectile_scenes[key], pool_size_per_type)

func _initialize_pool(key: String, scene: PackedScene, size: int) -> void:
	pools[key] = []
	for i in range(size):
		var instance = scene.instantiate()
		instance.visible = false
		instance.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(instance)
		pools[key].append(instance)

func get_projectile(key: String) -> Node:
	if not pools.has(key):
		if projectile_scenes.has(key):
			_initialize_pool(key, projectile_scenes[key], pool_size_per_type)
		else:
			return null
	
	var pool = pools[key]
	for instance in pool:
		if not is_instance_valid(instance):
			var new_instance = projectile_scenes[key].instantiate()
			add_child(new_instance)
			pool.append(new_instance)
			_reset_projectile(new_instance)
			new_instance.visible = true
			new_instance.process_mode = Node.PROCESS_MODE_INHERIT
			return new_instance
		if not instance.visible:
			_reset_projectile(instance)
			instance.visible = true
			instance.process_mode = Node.PROCESS_MODE_INHERIT
			return instance
	
	# Pool exhausted - create new
	var new_instance = projectile_scenes[key].instantiate()
	add_child(new_instance)
	pool.append(new_instance)
	_reset_projectile(new_instance)
	new_instance.visible = true
	new_instance.process_mode = Node.PROCESS_MODE_INHERIT
	return new_instance

func return_projectile(key: String, projectile: Node) -> void:
	if is_instance_valid(projectile):
		if projectile.has_method("on_despawn"):
			projectile.on_despawn()
		if projectile.has_method("reset_state"):
			projectile.reset_state()
		projectile.visible = false
		projectile.process_mode = Node.PROCESS_MODE_DISABLED

func _reset_projectile(instance: Node) -> void:
	instance.position = Vector2(-1000, -1000)
	if instance.has_method("reset_state"):
		instance.reset_state()