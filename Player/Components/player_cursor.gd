extends Node

@onready var player = get_parent()

var normal_cursor: Texture2D
var attack_cursor: Texture2D

func _ready():
	_attempt_load_cursors()

func _process(_delta: float):
	_update_cursor()

func _attempt_load_cursors():
	pass

func _update_cursor() -> void:
	var mouse_pos = player.get_global_mouse_position()
	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 5
	
	var results = space_state.intersect_point(query, 1)
	
	if results.size() > 0:
		var collider = results[0].collider
		if collider.is_in_group("enemy"):
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			return
	
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)