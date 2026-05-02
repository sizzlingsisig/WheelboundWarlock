# New Attacks Implementation Plan: Dark Bolt & Lightning

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two new weapon attacks (Dark Bolt and Lightning) that spawn on enemies from above with 4 upgrade tiers each.

**Architecture:** Dual-timer pattern (replenish timer + attack timer) matching existing weapons like Ice Spear. Dark Bolt spawns instantly on random enemy. Lightning chains between nearby enemies.

**Tech Stack:** Godot 4.x, GDScript

---

### Task 1: Create Dark Bolt Script

**Files:**
- Create: `Player/Attack/dark_bolt.gd`

- [ ] **Step 1: Write dark_bolt.gd script**

```gdscript
extends Area2D

var level = 1
var hp = 1
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	match level:
		1:
			hp = 1
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 1
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 1
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 1
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
	
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
```

---

### Task 2: Create Lightning Script

**Files:**
- Create: `Player/Attack/lightning.gd`

- [ ] **Step 1: Write lightning.gd script**

```gdscript
extends Area2D

var level = 1
var hp = 1
var damage = 5
var knockback_amount = 80
var attack_size = 1.0
var chain_count = 1
var chain_range = 150.0

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	match level:
		1:
			hp = 1
			damage = 5
			knockback_amount = 80
			attack_size = 1.0 * (1 + player.spell_size)
			chain_count = 1
		2:
			hp = 1
			damage = 5
			knockback_amount = 80
			attack_size = 1.0 * (1 + player.spell_size)
			chain_count = 2
		3:
			hp = 1
			damage = 8
			knockback_amount = 80
			attack_size = 1.0 * (1 + player.spell_size)
			chain_count = 2
		4:
			hp = 1
			damage = 8
			knockback_amount = 80
			attack_size = 1.0 * (1 + player.spell_size)
			chain_count = 3
	
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,0.3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
	# Chain to nearby enemies
	chain_to_nearby_enemies()

func chain_to_nearby_enemies():
	var enemies = player.enemy_close
	var target_enemies = []
	
	for enemy in enemies:
		if enemy == get_parent() or enemy in target_enemies:
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= chain_range and target_enemies.size() < chain_count:
			target_enemies.append(enemy)
			# Apply damage to chained enemy
			if enemy.has_method("_on_hurt_box_hurt"):
				enemy._on_hurt_box_hurt(damage, 0, knockback_amount)

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
```

---

### Task 3: Create Dark Bolt Scene

**Files:**
- Create: `Player/Attack/dark_bolt.tscn`

- [ ] **Step 1: Write dark_bolt.tscn scene**

```gdscript
[gd_scene format=3 uid="uid://darkbolt123"]

[ext_resource type="Script" path="res://Player/Attack/dark_bolt.gd" id="1_darkbolt"]
[ext_resource type="Texture2D" uid="uid://darkbolttex" path="res://assets/kalboWheelchair/Dark-Bolt.png" id="2_darkbolt"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_db"]
size = Vector2(32, 32)

[node name="DarkBolt" type="Area2D" groups=["attack"]]
top_level = true
scale = Vector2(0.1, 0.1)
collision_layer = 4
collision_mask = 0
script = ExtResource("1_darkbolt")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_darkbolt")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_db")

[node name="Timer" type="Timer" parent="."]
wait_time = 5.0
one_shot = true
autostart = true

[connection signal="timeout" from="Timer" to="." method="_on_timer_timeout"]
```

---

### Task 4: Create Lightning Scene

**Files:**
- Create: `Player/Attack/lightning.tscn`

- [ ] **Step 1: Write lightning.tscn scene**

```gdscript
[gd_scene format=3 uid="uid://lightning123"]

[ext_resource type="Script" path="res://Player/Attack/lightning.gd" id="1_lightning"]
[ext_resource type="Texture2D" uid="uid://lightningtex" path="res://assets/kalboWheelchair/Lightning.png" id="2_lightning"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_lt"]
size = Vector2(48, 48)

[node name="Lightning" type="Area2D" groups=["attack"]]
top_level = true
scale = Vector2(0.1, 0.1)
collision_layer = 4
collision_mask = 0
script = ExtResource("1_lightning")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_lightning")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_lt")

[node name="Timer" type="Timer" parent="."]
wait_time = 5.0
one_shot = true
autostart = true

[connection signal="timeout" from="Timer" to="." method="_on_timer_timeout"]
```

---

### Task 5: Add Upgrade Definitions

**Files:**
- Modify: `Utility/upgrade_db.gd`

- [ ] **Step 1: Add darkbolt and lightning upgrades to UPGRADES dict**

Add these entries after the tornado entries (around line 102):

```gdscript
	"darkbolt1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Dark Bolt",
		"details": "A dark bolt strikes a random enemy from above",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"darkbolt2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Dark Bolt",
		"details": "An additional Dark Bolt strikes",
		"level": "Level: 2",
		"prerequisite": ["darkbolt1"],
		"type": "weapon"
	},
	"darkbolt3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Dark Bolt",
		"details": "Dark Bolt damage increased by 3",
		"level": "Level: 3",
		"prerequisite": ["darkbolt2"],
		"type": "weapon"
	},
	"darkbolt4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Dark Bolt",
		"details": "Two additional Dark Bolts strike",
		"level": "Level: 4",
		"prerequisite": ["darkbolt3"],
		"type": "weapon"
	},
	"lightning1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning",
		"details": "Lightning strikes and chains to 1 nearby enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"lightning2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning",
		"details": "Lightning chains to 1 additional enemy",
		"level": "Level: 2",
		"prerequisite": ["lightning1"],
		"type": "weapon"
	},
	"lightning3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning",
		"details": "Lightning damage increased by 3",
		"level": "Level: 3",
		"prerequisite": ["lightning2"],
		"type": "weapon"
	},
	"lightning4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning",
		"details": "Lightning chains to 1 additional enemy",
		"level": "Level: 4",
		"prerequisite": ["lightning3"],
		"type": "weapon"
	},
```

---

### Task 6: Add Player Integration

**Files:**
- Modify: `Player/player.gd`

- [ ] **Step 1: Add preload and variables for new attacks**

Add after line 17 (javelin preload):
```gdscript
var darkBolt = preload("res://Player/Attack/dark_bolt.tscn")
var lightning = preload("res://Player/Attack/lightning.tscn")
```

Add after line 24 (javelinBase):
```gdscript
@onready var darkBoltTimer = get_node("%DarkBoltTimer")
@onready var darkBoltAttackTimer = get_node("%DarkBoltAttackTimer")
@onready var lightningTimer = get_node("%LightningTimer")
@onready var lightningAttackTimer = get_node("%LightningAttackTimer")
```

Add after line 49 (javelin variables):
```gdscript
#DarkBolt
var darkbolt_ammo = 0
var darkbolt_baseammo = 0
var darkbolt_attackspeed = 1.5
var darkbolt_level = 0

#Lightning
var lightning_ammo = 0
var lightning_baseammo = 0
var lightning_attackspeed = 2.0
var lightning_level = 0
```

- [ ] **Step 2: Add attack() function updates**

Add to attack() function after line 119:
```gdscript
	if darkbolt_level > 0:
		darkBoltTimer.wait_time = darkbolt_attackspeed * (1-spell_cooldown)
		if darkBoltTimer.is_stopped():
			darkBoltTimer.start()
	if lightning_level > 0:
		lightningTimer.wait_time = lightning_attackspeed * (1-spell_cooldown)
		if lightningTimer.is_stopped():
			lightningTimer.start()
```

- [ ] **Step 3: Add timer callback functions**

Add after line 198 (end of javelin functions):
```gdscript
func _on_dark_bolt_timer_timeout():
	darkbolt_ammo += darkbolt_baseammo + additional_attacks
	darkBoltAttackTimer.start()

func _on_dark_bolt_attack_timer_timeout():
	if darkbolt_ammo > 0:
		var target = get_random_target()
		if target != Vector2.UP:
			var darkbolt_attack = darkBolt.instantiate()
			darkbolt_attack.position = target
			darkbolt_attack.level = darkbolt_level
			add_child(darkbolt_attack)
		darkbolt_ammo -= 1
		if darkbolt_ammo > 0:
			darkBoltAttackTimer.start()
		else:
			darkBoltAttackTimer.stop()

func _on_lightning_timer_timeout():
	lightning_ammo += lightning_baseammo + additional_attacks
	lightningAttackTimer.start()

func _on_lightning_attack_timer_timeout():
	if lightning_ammo > 0:
		var target = get_random_target()
		if target != Vector2.UP:
			var lightning_attack = lightning.instantiate()
			lightning_attack.position = target
			lightning_attack.level = lightning_level
			add_child(lightning_attack)
		lightning_ammo -= 1
		if lightning_ammo > 0:
			lightningAttackTimer.start()
		else:
			lightningAttackTimer.stop()
```

- [ ] **Step 4: Add upgrade_character matches**

Add to upgrade_character() function after line 304 (after javelin4):
```gdscript
		"darkbolt1":
			darkbolt_level = 1
			darkbolt_baseammo += 1
		"darkbolt2":
			darkbolt_level = 2
			darkbolt_baseammo += 1
		"darkbolt3":
			darkbolt_level = 3
		"darkbolt4":
			darkbolt_level = 4
			darkbolt_baseammo += 2
		"lightning1":
			lightning_level = 1
			lightning_baseammo += 1
		"lightning2":
			lightning_level = 2
		"lightning3":
			lightning_level = 3
		"lightning4":
			lightning_level = 4
```

---

### Task 7: Add Timer Nodes to Player Scene

**Files:**
- Modify: `Player/player.tscn`

- [ ] **Step 1: Add DarkBolt and Lightning timer nodes**

Add after the JavelinBase node (around line 158):
```
[node name="DarkBoltTimer" type="Timer" parent="Attack" unique_id=db_timer1]
wait_time = 1.5

[node name="DarkBoltAttackTimer" type="Timer" parent="Attack/DarkBoltTimer" unique_id=db_timer2]
wait_time = 0.3

[node name="LightningTimer" type="Timer" parent="Attack" unique_id=lt_timer1]
wait_time = 2.0

[node name="LightningAttackTimer" type="Timer" parent="Attack/LightningTimer" unique_id=lt_timer2]
wait_time = 0.3
```

- [ ] **Step 2: Add signal connections**

Add connections:
```
[connection signal="timeout" from="Attack/DarkBoltTimer" to="." method="_on_dark_bolt_timer_timeout"]
[connection signal="timeout" from="Attack/DarkBoltTimer/DarkBoltAttackTimer" to="." method="_on_dark_bolt_attack_timer_timeout"]
[connection signal="timeout" from="Attack/LightningTimer" to="." method="_on_lightning_timer_timeout"]
[connection signal="timeout" from="Attack/LightningTimer/LightningAttackTimer" to="." method="_on_lightning_attack_timer_timeout"]
```

---

### Task 8: Test in Editor

**Files:**
- Test: Open `World/world.tscn` and run game

- [ ] **Step 1: Verify game runs without errors**

Press F5 in Godot editor to run the game. Check for any runtime errors in the console.

- [ ] **Step 2: Verify attacks can be selected**

Start a new game, level up, and verify Dark Bolt and Lightning appear as upgrade options.

- [ ] **Step 3: Verify attacks function correctly**

Select the new attacks and verify:
- Dark Bolt spawns on enemy position
- Lightning spawns and chains to nearby enemies

---

## Execution Choice

**Plan complete and saved to `docs/superpowers/plans/2026-05-02-new-attacks-plan.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**