extends Node

enum State { MENU, PLAYING, UPGRADE, GAME_OVER, WIN }

var current_state: State = State.MENU

signal state_changed(new_state: State)

func set_state(new_state: State) -> void:
	if current_state != new_state:
		current_state = new_state
		emit_signal("state_changed", new_state)

func is_playing() -> bool:
	return current_state == State.PLAYING

func can_move() -> bool:
	return current_state == State.PLAYING

func can_attack() -> bool:
	return current_state == State.PLAYING

func is_paused() -> bool:
	return current_state == State.UPGRADE or current_state == State.GAME_OVER or current_state == State.WIN