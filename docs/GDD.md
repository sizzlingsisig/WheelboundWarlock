# KALBO: The Path of Baldness
### Game Design Document
**Genre:** Action Roguelike &nbsp;|&nbsp; **Engine:** Godot 4 &nbsp;|&nbsp; **Version:** 1.0 &nbsp;|&nbsp; **Date:** April 2026

> *"Ascension Through Attributes"*

---

## 1. Program Vision

Kalbo: The Path of Baldness is a high-performance Action-Roguelike built in Godot 4. It blends the "reverse bullet-hell" scaling of Vampire Survivors with the tactical manual combat of traditional ARPGs.

**Core Identity:** Players' stat investments dictate both their physical appearance and their mechanical capabilities. No two runs evolve the same way.

The game challenges players to make meaningful upgrade decisions under pressure, rewarding focused stat investment with powerful class evolutions that fundamentally change how they play.

---

## 2. Core Gameplay Mechanics

### 2.1 The Hybrid Combat Triad

The player manages three distinct weapon systems simultaneously, creating a layered combat loop that rewards both active engagement and strategic build planning:

- **Manual Melee (Left Click)** — Demands precise timing to maximize stagger and zone control.
- **Special Ability (Right Click)** — Utility-focused active skill (Dash, Shield, Teleport) governed by a cooldown timer.
- **Auto-Projectiles (Passive)** — Weapons gained through Augments that fire automatically based on internal timers; scale with the build.

### 2.2 The Strand Ascension System

> **Design Twist:** Evolutions are not guaranteed by level — they are earned through Stat Thresholds. This turns every augment pickup into a strategic decision.

The Ascension flow unfolds in four stages:

1. **Starter State** — Player begins as Normal Kalbo with no evolution unlocked.
2. **Stat Augmentation** — Players collect Common Augments to increase STR, AGI, or INT.
3. **Condition Check** — Once a stat reaches 15, the corresponding Strand Evolution Card enters the random upgrade pool.
4. **Immediate Replacement** — Upon selection, the player's Sprite, Stats, Manual Melee, and Special Ability are instantly replaced to reflect the new class identity.

---

## 3. Technical Architecture

### 3.1 Data-Driven Composition

To satisfy the "Composition Over Inheritance" requirement, all character and weapon data is defined as Godot Resources rather than hardcoded class hierarchies:

- Every Character and Weapon is a `Resource` (`.tres` file). Stats, sprites, and ability references are properties on the Resource, not baked into scene nodes.
- The Player node contains `Marker2D` slots for weapon attachment points. To evolve, the game calls `queue_free()` on old children and `instantiate()`s the new scenes defined in the selected `StrandResource`.
- This ensures the evolution system is entirely data-driven — adding a new Strand requires only a new `.tres` file, with zero code changes.

### 3.2 Performance & Entity Management

- **Object Pooling** — A centralized `PoolManager` handles all Enemies and Projectiles. Objects are recycled rather than destroyed, keeping GC pressure near zero during peak enemy density.
- **Physics Layers** — Distinct collision layers are assigned for `Player`, `Enemy`, `PlayerProjectile`, and `XP_Gem`, minimising unnecessary collision callbacks across the physics engine.

### 3.3 State Machine (FSM) Hierarchy

| FSM | States | Notes |
|---|---|---|
| **Global FSM** | `MENU` → `PLAYING` ↔ `UPGRADE (Paused)` → `GAME_OVER` | Controls top-level game flow. UPGRADE state pauses gameplay and presents the augment selection screen. |
| **Enemy FSM** | `SPAWN` → `CHASE` → `HURT` → `DEATH` | Drives per-enemy behavior. Transitions are triggered by proximity, damage events, and HP reaching zero. |

---

## 4. Character Classes — The Strands

Each Strand represents a distinct mechanical identity. Evolving is permanent for the run; the player's entire combat toolset is replaced on selection.

| Strand | Sprite | Requirement | Melee (L-Click) | Special (R-Click) |
|---|---|---|---|---|
| **Normal** | Tunic Kalbo | N/A *(Starter)* | Quick Slap | Sweat Dash |
| **Muscle** | Buff Kalbo | 15 STR | Heavy Smash | Flex Shield |
| **Knight** | Plate Armor | 15 INT / Faith | Wide Cleave | Bulwark Block |
| **Magician** | Robed Chair | 15 AGI | Magic Missile | Mana Blink |

### Design Intent per Strand

- **Normal** — Flexible starting class with low commitment. Encourages players to explore the augment pool before committing to a path.
- **Muscle** — Frontline brawler. Heavy Smash + Flex Shield reward aggressive positioning and timing. Pairs best with HP and melee-range auto-projectiles.
- **Knight** — Defensive anchor. Bulwark Block enables reactionary play; Wide Cleave controls grouped enemies. High synergy with area-denial weapon augments.
- **Magician** — Highly mobile caster. Mana Blink repositions instantly; Magic Missile provides safe ranged poke. Rewards maximising auto-projectile coverage.

---

## 5. Progression & Difficulty Scaling

### 5.1 Augment Categories

| Category | Rarity | Effect |
|---|---|---|
| **Stat Cards** | Common | Direct +5 to a primary attribute (STR, AGI, or INT). The foundation of every build. |
| **Weapon Cards** | Common | Unlocks a new auto-firing projectile (e.g., Dandruff Flakes) that fires on its own internal timer. |
| **Evolution Cards** | Rare — Golden | Triggers full class replacement when the stat threshold is met. Replaces sprite, stats, melee, and special ability. |

### 5.2 Escalation Logic

Difficulty follows a linear curve to ensure a consistent and predictable power ramp:

```
D(t) = (BaseRate × t) + ScaleFactor
```

- Every 60 seconds, enemy HP increases by **10%**.
- Every 60 seconds, spawn frequency increases by **15%**.
- The **Scalp Overlord** boss is summoned at the 10-minute mark, serving as the final difficulty spike.

---

## 6. Visual & Audio Design

### 6.1 Art Direction

- 4-directional LPC sprites maintain a cohesive pixel-art aesthetic across all Strand evolutions and enemy types.
- Each Strand's silhouette is immediately readable at a glance, ensuring the player recognises their class during hectic combat.

### 6.2 Juice & Feedback

- **Screen Shake** — Triggers on every Heavy Melee hit, reinforcing the impact of manual combat.
- **Ascension VFX** — Chromatic aberration flashes during the Ascension moment, signalling the class transformation as a dramatic event.
- **Floating Numbers** — Damage numbers are spawned from a pool and rise off enemies, giving clear moment-to-moment DPS feedback without impacting performance.

### 6.3 Sound Design

- **Music** — Low-bit synth music for gameplay; energetic and loopable without fatigue.
- **SFX** — High-impact "crunchy" SFX for manual melee hits, reinforcing the tactile satisfaction of the primary attack.

---

## 7. Win / Loss Conditions

### 7.1 Loss Condition

The player is eliminated when their HP reaches 0. There are no revives or checkpoints; each run is a complete cycle.

### 7.2 Win Condition

Victory is achieved in two stages:

1. **Phase 1** — Survive for 10 minutes (Testing Phase target) against the escalating enemy horde.
2. **Phase 2** — Defeat the **Scalp Overlord** (Final Boss) who spawns at the end of the timer.

> **Testing Phase Note:** The 10-minute win timer is the current playtesting benchmark. Run length and boss spawn timing are subject to tuning based on difficulty feedback gathered during internal testing.