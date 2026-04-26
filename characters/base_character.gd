extends Node2D
class_name BaseCharacter

@export var default_visual: String = "kalboarmor"
var active_sprite: AnimatedSprite2D
var sprite_nodes: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			sprite_nodes[child.name] = child
			child.visible = false
			child.stop()

	set_visual(default_visual)

func set_visual(visual_name: String) -> void:
	if not sprite_nodes.has(visual_name):
		return

	for sprite in sprite_nodes.values():
		sprite.visible = false
		sprite.stop()

	active_sprite = sprite_nodes[visual_name]
	active_sprite.visible = true

	var animation_to_play = "idle_down"
	if active_sprite.animation != "":
		animation_to_play = active_sprite.animation
	set_animation(animation_to_play)

func set_animation(animation_name: String) -> void:
	if not active_sprite or not active_sprite.sprite_frames:
		return

	if active_sprite.sprite_frames.has_animation(animation_name):
		active_sprite.animation = animation_name
		active_sprite.play()

func set_direction(direction: Vector2, moving: bool) -> void:
	if not active_sprite:
		return

	var anim_name = "idle_down"
	if moving and direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				anim_name = "walk_right"
			else:
				anim_name = "walk_left"
		else:
			if direction.y > 0:
				anim_name = "walk_down"
			else:
				anim_name = "walk_up"
	else:
		if direction.x > 0:
			anim_name = "idle_right"
		elif direction.x < 0:
			anim_name = "idle_left"
		elif direction.y < 0:
			anim_name = "idle_up"
		else:
			anim_name = "idle_down"

	set_animation(anim_name)
