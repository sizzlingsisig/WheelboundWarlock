extends Control

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	visible = false

func show_pause():
	get_tree().paused = true
	GameState.set_state(GameState.State.UPGRADE)
	visible = true

func hide_pause():
	get_tree().paused = false
	GameState.set_state(GameState.State.PLAYING)
	visible = false

func _on_resume_pressed():
	hide_pause()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")