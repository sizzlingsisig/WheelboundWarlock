# WHEELBOUND WARLOCK: PERSON WITH THIS ABILITY
### Game Design Document
**Genre:** Action Roguelike &nbsp;|&nbsp; **Engine:** Godot 4 &nbsp;|&nbsp; **Version:** 1.0 &nbsp;|&nbsp; **Date:** May 2026

---

## 1. Program Vision

**Kalbo vs the World** is a high-performance Action-Roguelike built in Godot 4, inspired by Vampire Survivors. Players survive waves of enemies, collect experience gems, level up, and defeat the boss to win!

**Core Identity:** Fast-paced survival action with manual weapon control and strategic upgrade decisions.

---

## 2. Core Gameplay Mechanics

### 2.1 Manual Combat System

Unlike traditional Vampire Survivors where weapons fire automatically, this game requires the player to manually trigger each weapon attack:

- **Manual Attack Control** — Each weapon has its own key binding
- Player must press the correct key to fire each weapon
- Strategic timing and positioning become crucial
- Creates a more action-oriented experience

### 2.2 Progression Flow

1. **Start** — Player begins with no weapons
2. **Collect Gems** — Defeat enemies to collect XP gems
3. **Level Up** — Choose a new weapon or upgrade
4. **Survive** — Survive until the 5-minute boss
5. **Defeat Boss** — Kill the Giant Amoeba to win

---

## 3. Technical Architecture

### 3.1 Data-Driven Design

All character and weapon data is defined as Godot Resources:

- Every Weapon is a `Resource` with stats, damage, sprites
- Upgrade database is data-driven via `upgrade_db.gd`
- New weapons can be added via `.tres` files

### 3.2 Performance & Entity Management

- **Object Pooling** — Centralized pool for enemies
- **Physics Layers** — Distinct collision layers for Player, Enemy, Projectile

### 3.3 State Machine

| FSM | States | Notes |
|---|---|---|
| Global | MENU → PLAYING ↔ UPGRADE → GAME_OVER/WIN | Top-level game flow |
| Enemy | SPAWN → MOVE → HURT → DEAD | Per-enemy behavior |

---

## 4. Weapons

| Weapon | Key | Type | Description |
|--------|-----|------|-------|
| Ice Spear | 1 | Projectile | Seeks enemies |
| Tornado | 2 | AoE | Damage around player |
| Javelin | - | Orbital | Attacks automatically |
| Lightning | 4 | Chain | Strikes and chains to nearby |
| Immolate | 3 | Aura | Fire contact damage |
| Hollow Purple | - | Zone | Persistent damage |
| Will O Whisps | - | Orbital | Rotating orbs |

---

## 5. Enemies

| Enemy | HP | Speed | Damage | Notes |
|-------|-----|-------|-------|-------|
| Kobold (Weak) | 5 | 30 | 1 | Basic enemy |
| Kobold (Strong) | 20 | 30+ | 2 | More HP |
| Cyclops | 100 | 30+ | 5 | Large enemy |
| Juggernaut | 300 | 30+ | 8 | Tanky enemy |
| Giant Amoeba | 750 | 100 | 20 | Boss |

---

## 6. Boss Mechanics

### Giant Amoeba (Boss)

- **HP:** 750
- **Speed:** 100
- **Damage:** 20 (contact), 15-20 (special attacks)
- **Attack Interval:** ~5 seconds
- **Abilities:**
  - Teleport — Teleports behind player when far
  - Slam — Close-range damage attack
- **Win Condition:** Defeating boss triggers win screen

---

## 7. Game States

| State | Description |
|-------|------------|
| MENU | Title screen |
| PLAYING | Active gameplay |
| UPGRADE | Level up selection (paused) |
| GAME_OVER | Player died |
| WIN | Boss defeated |

---

## 8. Controls

| Action | Input |
|--------|-------|
| Move | Right Click |
| Pause | ESC |
| Ice Spear | 1 |
| Tornado | 2 |
| Immolate | 3 |
| Lightning | 4 |

---

*Last Updated: May 2026*