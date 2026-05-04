extends Area2D

@export var experience: int = 1

var spr_green: Texture2D = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue: Texture2D = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red: Texture2D = preload("res://Textures/Items/Gems/Gem_red.png")

var target: Node = null
var speed: float = -1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound: AudioStreamPlayer = $snd_collected

func _ready() -> void:
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta

func collect() -> int:
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return experience


func _on_snd_collected_finished() -> void:
	queue_free()
