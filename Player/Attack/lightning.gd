extends Area2D

const STRIKE_WINDUP = 0.12
const STRIKE_HIT_WINDOW = 0.12

var level = 1
var hp = 1
var damage = 5
var knockback_amount = 80
var attack_size = 1.0
var chain_count = 1
var chain_range = 150.0
const PRIMARY_HIT_RADIUS = 32.0
var has_hit_window = false

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var timer = $Timer

func _ready():
	sprite.play()
	collision.call_deferred("set","disabled",true)
	var spell_size = 0.0
	if player != null:
		spell_size = player.spell_size
	match level:
		1:
			hp = 1
			damage = 5
			knockback_amount = 80
			attack_size = 1.0 * (1 + spell_size)
			chain_count = 1
		2:
			hp = 1
			damage = 5
			knockback_amount = 80
			attack_size = 1.0 * (1 + spell_size)
			chain_count = 2
		3:
			hp = 1
			damage = 8
			knockback_amount = 80
			attack_size = 1.0 * (1 + spell_size)
			chain_count = 2
		4:
			hp = 1
			damage = 8
			knockback_amount = 80
			attack_size = 1.0 * (1 + spell_size)
			chain_count = 3
	
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,STRIKE_WINDUP).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	timer.wait_time = STRIKE_WINDUP
	timer.start()

func chain_to_nearby_enemies():
	if player == null or chain_count <= 0:
		return
	
	var enemies: Array = player.enemy_close.duplicate()
	var chain_targets = []
	var effective_chain_range = chain_range * attack_size
	var primary_hit_radius = PRIMARY_HIT_RADIUS * attack_size
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.is_queued_for_deletion():
			continue
		if not enemy.has_method("_on_hurt_box_hurt"):
			continue
		
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= effective_chain_range:
			chain_targets.append({
				"enemy": enemy,
				"distance": dist
			})
	
	if chain_targets.is_empty():
		return
	
	chain_targets.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
	var start_index = 0
	if chain_targets[0]["distance"] <= primary_hit_radius:
		start_index = 1
	
	var hit_count = 0
	for index in range(start_index, chain_targets.size()):
		if hit_count >= chain_count:
			break
		
		var enemy = chain_targets[index]["enemy"]
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		
		var knockback_direction = global_position.direction_to(enemy.global_position)
		enemy._on_hurt_box_hurt(damage, knockback_direction, knockback_amount)
		hit_count += 1

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		remove_lightning()

func remove_lightning():
	if is_queued_for_deletion():
		return
	emit_signal("remove_from_array",self)
	queue_free()

func _on_timer_timeout():
	if has_hit_window == false:
		has_hit_window = true
		collision.call_deferred("set","disabled",false)
		chain_to_nearby_enemies()
		timer.wait_time = STRIKE_HIT_WINDOW
		timer.start()
	else:
		collision.call_deferred("set","disabled",true)
		remove_lightning()
