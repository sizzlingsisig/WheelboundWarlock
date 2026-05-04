# Process Level Document
### Wheelbound Warlock: Person with this ability
**Engine:** Godot 4 &nbsp;|&nbsp; **Date:** May 2026

---

## 1. Overview

This document describes the game's runtime processes - what happens each frame, each second, and during key game events.

---

## 2. Main Game Loop

### 2.1 Frame Process (_process)

Runs every frame (~60 FPS):

```
Player Input Check
    ↓
If MOVING: Update movement target position
    ↓
Update player position/velocity via move_and_slide()
    ↓
Update sprite animation based on direction
    ↓
Process weapon timers (cooldowns)
    ↓
Process XP gems following player
```

### 2.2 Physics Process (_physics_process)

Runs every physics frame (fixed timestep):

```
If PLAYING state:
    ↓
Check for nearby enemies (auto-target)
    ↓
Process weapon timers
    ↓
Check for level up (XP threshold)
```

### 2.3 Timer-Based Processes

**Enemy Spawner Timer (1 second interval):**

```
time += 1
    ↓
For each spawn config:
    - Check if time within [time_start, time_end]
    - Check spawn_delay counter
    → Spawn enemy(s)
    ↓
Check if time == 300 (5 min)
    → Spawn Boss
    ↓
Emit "changetime" signal
```

**Weapon Cooldown Timers:**

```
Ice Spear: 1.5s cooldown
Tornado: 2.0s cooldown
Lightning: 2.0s cooldown
Immolate: 1.5s cooldown
```

---

## 3. Input Handling

### 3.1 Movement Input

```
Right Mouse Click
    ↓
Get click position (screen coordinates)
    ↓
Store as movement_target
    ↓
Player moves toward target each frame
    ↓
Stop when distance < stop_distance (16px)
```

### 3.2 Attack Input

```
Number Keys (1-4)
    ↓
Check cooldown timer for that weapon
    ↓
If ready: trigger_<weapon>_attack()
    ↓
Get projectile from pool
    ↓
Configure projectile (damage, target)
    ↓
Start cooldown timer
```

---

## 4. Combat Processes

### 4.1 Player Attacking

```
Input received
    ↓
Call combat_component.spawn_<spell>()
    ↓
pool.get_projectile("<spell>")
    ↓
Configure projectile:
    - Set damage based on weapon level
    - Set speed, special properties
    - Set target position
    ↓
Add to scene at player position
    ↓
Projectile follows/moves based on type
```

### 4.2 Projectile Lifecycle

```
Spawn
    ↓
[Per frame] Move in configured direction
    ↓
[If Area2D] Monitor for collisions
    ↓
On collision with Enemy HurtBox:
    - Call enemy._on_hurt_box_hurt(damage, angle, knockback)
    - Apply knockback to enemy.hitBox
    ↓
Timer reaches timeout
    ↓
pool.return_projectile() → Return to pool
```

### 4.3 Enemy Taking Damage

```
Projectile/Attack hits HurtBox
    ↓
HurtBox._on_area_entered(area)
    ↓
Check HurtBoxType:
    - 0 (Cooldown): Disable collision for 0.5s
    - 1 (HitOnce): Track hit, don't hit same projectile twice
    - 2 (DisableHitBox): Call area.tempdisable()
    ↓
Emit "hurt" signal with damage/knockback
    ↓
Enemy._on_hurt_box_hurt(damage, angle, knockback)
    ↓
Apply knockback (velocity += angle * knockback_amount)
    ↓
Apply damage (enemy.hp -= damage)
    ↓
If hp <= 0:
    - Play death animation
    - Drop XP gem
    - Return enemy to pool
```

### 4.4 Enemy Attacking Player

```
Enemy moves toward player each frame
    ↓
If Enemy HitBox overlaps Player HurtBox
    ↓
Player._on_hurt_box_hurt(damage, angle, knockback)
    ↓
Apply damage to player (player.hp -= damage)
    ↓
If player.hp <= 0:
    - Emit "playerdeath" signal
    - Set GameState to GAME_OVER
    - Show defeat panel
```

---

## 5. Enemy Spawning Process

### 5.1 Initial Spawn (time_start = 0)

```
Game starts (WORLD._ready())
    ↓
EnemySpawner._ready()
    ↓
Call _spawn_initial_enemies()
    ↓
For each spawn config with time_start == 0:
    - Get random edge position
    - _spawn_from_pool() for enemy_num times
```

### 5.2 Timed Spawns

```
Timer fires every 1 second
    ↓
Increment time counter
    ↓
For each spawn config:
    - If time >= time_start AND time <= time_end:
        - If spawn_delay_counter < enemy_spawn_delay:
            - Increment spawn_delay_counter
        - Else:
            - Reset counter to 0
            - Spawn enemy_num enemies
    ↓
If time == 300 AND boss not spawned:
    - Spawn Boss (boss_scene)
    - Set boss_spawned = true
```

### 5.3 Spawn Position Calculation

```
get_random_position()
    ↓
Calculate viewport size * random (1.1 to 1.4)
    ↓
Calculate spawn area (one of 4 sides randomly)
    ↓
Return random position along that edge
```

---

## 6. XP and Leveling Process

### 6.1 XP Collection

```
Player moves near XP gem (within collection radius)
    ↓
Gem.target = player
    ↓
Gem moves toward player
    ↓
On overlap: Player._on_collect_area_area_entered()
    ↓
Call area.collect() → returns XP value
    ↓
Player.calculate_experience(gem_exp)
```

### 6.2 Level Up Check

```
calculate_experience()
    ↓
If (experience + collected_experience) >= exp_required:
    - collected_experience -= (exp_required - experience)
    - experience_level += 1
    - experience = 0
    - Trigger levelup()
```

### 6.3 Level Up Flow

```
Player enters UPGRADE state
    ↓
Show upgrade selection panel
    ↓
Player picks an upgrade
    ↓
Add upgrade to collected_upgrades
    ↓
Refresh weapon stats
    ↓
Return to PLAYING state
```

---

## 7. Boss Process

### 7.1 Boss Spawn (at 5 minutes)

```
Timer reaches time == 300
    ↓
Check if boss_spawned == false
    ↓
If boss_scene assigned:
    - spawn_boss()
    - Create boss at random edge position
    - Add to scene
    - Set boss_spawned = true
```

### 7.2 Boss Behavior

```
Boss (enemy_super) uses enemy.gd with boss attacks
    ↓
Every ~5 seconds (attack_interval):
    - If distance > 100: Teleport behind player
    - Else: Slam attack (damage nearby)
```

### 7.3 Boss Defeat → Win

```
Boss HP reaches 0
    ↓
Enemy.death():
    - If in "boss" group:
        - Emit "boss_defeated" signal
    ↓
Player._on_boss_defeated()
    ↓
Set boss_alive = false
    ↓
Call win_game()
    ↓
Set GameState to WIN
    ↓
Show victory panel
```

---

## 8. Game Over Process

### 8.1 Player Death

```
Player HP reaches 0
    ↓
Player._on_hurt_box_hurt()
    ↓
Emit "playerdeath" signal
    ↓
Set GameState to GAME_OVER
    ↓
Pause game (get_tree().paused = true)
    ↓
Show defeat panel
    ↓
Play lose sound
```

### 8.2 Restart

```
Player clicks "Menu" button
    ↓
Call _on_btn_menu_click_end()
    ↓
Set GameState to MENU
    ↓
Change scene to menu.tscn
    ↓
Reset all game state
```

---

## 9. Pause Process

```
ESC key pressed
    ↓
If PAUSED: Unpause
    ↓
If PLAYING: Pause
    ↓
Toggle pause menu visibility
    ↓
get_tree().paused = true/false
```

---

## 10. State Transitions

```
MENU → PLAYING: Player clicks "Play"
    ↓
PLAYING → UPGRADE: Player levels up
    ↓
PLAYING → GAME_OVER: Player dies
    ↓
PLAYING → WIN: Boss defeated
    ↓
UPGRADE → PLAYING: Player selects upgrade
    ↓
GAME_OVER → MENU: Player returns to menu
    ↓
WIN → MENU: Player returns to menu
```

---

*Last Updated: May 2026*