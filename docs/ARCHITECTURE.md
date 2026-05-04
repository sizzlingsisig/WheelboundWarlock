# Architecture Logic Document
### Wheelbound Warlock: Person with this ability
**Engine:** Godot 4 &nbsp;|&nbsp; **Date:** May 2026

---

## 1. Overview

This document describes the logical architecture of the game, including the core systems, data flows, and design patterns used to build the game.

---

## 2. Core Architecture Patterns

### 2.1 Composition Over Inheritance

The game uses **composition over inheritance** for the weapon system:

- **Weapon Data** is stored as Godot `Resource` files (`.tres`)
- Weapons are attached to Player via `Marker2D` slots
- New weapons can be added via data files, not code changes
- `WeaponData` Resource contains all stats, sprites, and scene references

```
Weapon Scene (.tscn)
    ↓ uses
WeaponLevelData (.tres)
    ↓ configures
UpgradeDb (data-driven)
```

### 2.2 Data-Driven Design

All game data is defined externally:

- **Weapons:** `Resources/Weapons/*.tres`
- **Upgrades:** `Utility/upgrade_db.gd`
- **Spawn Rules:** `World/world.tscn` spawn configurations
- **Enemy Stats:** Individual enemy `.tscn` files

### 2.3 Object Pooling

Centralized pooling for high-frequency entities:

- **Enemy Pool:** `EnemySpawner.return_enemy_to_pool()`
- **Projectile Pool:** `ProjectilePool.get_projectile()` / `return_projectile()`

This reduces garbage collection pressure during peak enemy density.

---

## 3. System Architecture

### 3.1 Game State Machine (Global FSM)

```
States: MENU → PLAYING ↔ UPGRADE → GAME_OVER/WIN
```

| State | Behavior |
|-------|----------|
| MENU | Title screen, waiting for input |
| PLAYING | Active gameplay, timer running, spawns active |
| UPGRADE | Paused, showing upgrade selection |
| GAME_OVER | Player died, show defeat screen |
| WIN | Boss defeated, show victory screen |

**Implementation:** `GameState` autoload singleton

### 3.2 Enemy Behavior FSM

```
States: SPAWN → MOVE → DEAD
```

| State | Behavior |
|-------|----------|
| SPAWN | Brief spawn delay (0.5s) |
| MOVE | Chase player, handle knockback |
| DEAD | Play death animation, drop XP, return to pool |

**Implementation:** Base `enemy.gd` script

### 3.3 Combat System

**Manual Spell Casting Flow:**

```
Player Input (Key Press)
    ↓
Player.trigger_<spell>_attack()
    ↓
PlayerCombatComponent.spawn_<spell>()
    ↓
ProjectilePool.get_projectile("<spell>")
    ↓
Projectile spawned at player position
    ↓
Projectile moves/attacks based on type
    ↓
On timeout/despawn: projectile_pool.return_projectile()
```

---

## 4. Data Flow

### 4.1 Player → Enemy Damage

```
Player presses attack key (1, 2, 3, 4)
    ↓
Weapons fire via Projectile System
    ↓
Projectile hits Enemy HurtBox
    ↓
HurtBox emits "hurt" signal with damage/knockback
    ↓
Enemy._on_hurt_box_hurt() processes damage
    ↓
If HP <= 0: Enemy.death() → Drop XP Gem
```

### 4.2 Enemy → Player Damage

```
Enemy HitBox overlaps Player HurtBox
    ↓
HurtBox detects attack Area2D
    ↓
HurtBox calculates damage/knockback
    ↓
Player._on_hurt_box_hurt() processes damage
    ↓
If HP <= 0: Player enters GAME_OVER state
```

### 4.3 XP Collection

```
Enemy death → spawn XP Gem at position
    ↓
Player moves near Gem (CollectArea)
    ↓
Gem.target = Player, moves toward player
    ↓
Gem collected → Player.calculate_experience()
    ↓
If XP >= level_up_threshold: Enter UPGRADE state
```

---

## 5. Key Systems

### 5.1 Auto-Targeting System

```
Player detection area tracks nearby enemies
    ↓
enemy_close[] array updated on body_entered/exited
    ↓
get_random_target() or get_closest_target() returns position
    ↓
Weapons aim at target position
```

**Location:** `Player.enemy_close`, `Player.get_random_target()`

### 5.2 Spawn System

```
Game timer increments every second
    ↓
EnemySpawner checks spawn configurations
    ↓
For each spawn config:
    - If current time within [time_start, time_end]
    - If spawn_delay satisfied
    → Spawn enemy at random screen edge position
```

### 5.3 Upgrade System

```
XP collected → Player.experience increases
    ↓
When threshold reached: trigger levelup()
    ↓
GAME_OVER/UPGRADE state shows upgrade screen
    ↓
Player selects upgrade
    ↓
Weapon/spell added to player's loadout
```

---

## 6. Signal Communication

The game uses Godot signals for loose coupling:

| Signal | Sender | Receiver | Purpose |
|--------|-------|----------|---------|
| `hurt` | HurtBox | Enemy | Damage dealt |
| `remove_from_array` | Projectile | PlayerCombat | Clean up projectile list |
| `playerdeath` | Player | Game systems | Handle player death |
| `boss_defeated` | Enemy | Player | Trigger win state |
| `changetime` | EnemySpawner | Player | Update timer display |
| `state_changed` | GameState | UI systems | Update game state |

---

## 7. Scene Hierarchy

```
Main Scene (world.tscn)
├── Background (Sprite2D)
├── Player (CharacterBody2D)
│   ├── AnimatedSprite2D
│   ├── Camera2D
│   ├── CollisionShape2D
│   ├── HurtBox
│   ├── HitBox
│   ├── HealthBar
│   ├── Attack (Node2D)
│   │   └── [Weapon Timers]
│   └── GUILayer/GUI
│       ├── HealthBar (if in UI)
│       ├── SkillBar
│       ├── PauseMenu
│       └── LevelUp Panel
├── EnemySpawner (Node2D)
│   └── Timer
├── Loot (Node2D) - XP Gems
├── ProjectilePool (Node)
└── snd_Music (AudioStreamPlayer)
```

---

## 8. Resource Files

### Weapon Resources
```
Resources/Weapons/
├── ice_spear.tres    - Ice Spear weapon data
├── tornado.tres      - Tornado weapon data
├── javelin.tres       - Javelin weapon data
├── lightning.tres    - Lightning weapon data
├── immolate.tres     - Immolate weapon data
├── hollow_purple.tres - Hollow Purple weapon data
└── will_o_whisp.tres - Will O Whisps weapon data
```

### Enemy Resources
```
Enemy/
├── enemy_kobold_weak.tscn   - Basic enemy
├── enemy_kobold_strong.tscn - Strong enemy
├── enemy_cyclops.tscn      - Large enemy
├── enemy_juggernaut.tscn  - Tank enemy
├── enemy_super.tscn        - Boss
└── [etc.]
```

---

## 9. Key Classes

| Class | File | Purpose |
|-------|------|---------|
| Player | `Player/player.gd` | Player control, stats, input |
| PlayerCombat | `Player/Components/player_combat.gd` | Weapon spawning |
| EnemySpawner | `Utility/enemy_spawner.gd` | Spawn management |
| Enemy | `Enemy/enemy.gd` | Base enemy logic |
| UpgradeDb | `Utility/upgrade_db.gd` | Upgrade database |
| GameState | `Utility/game_state.gd` | Global state management |
| ProjectilePool | `Utility/projectile_pool.gd` | Projectile recycling |

---

*Last Updated: May 2026*