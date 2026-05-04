extends Node2D

var lifetime: float = 0.4
var elapsed: float = 0.0

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float):
	elapsed += delta
	modulate.a = 1.0 - (elapsed / lifetime)
	scale = Vector2.ONE * (1.0 + elapsed * 1.5)

func _draw():
	draw_circle(Vector2.ZERO, 8.0, Color(1, 1, 1, 0.5))
	draw_arc(Vector2.ZERO, 6.0, 0, TAU, 32, Color(1, 1, 1, 0.8), 2.0)