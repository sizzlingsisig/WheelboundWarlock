# New Attacks Design: Dark Bolt & Lightning

## Overview

Add two new weapon attacks to the game that spawn from above (meteor strike style) on enemies.

## Dark Bolt

**Behavior:** Instantly spawns on top of a random enemy dealing damage.

**Upgrade Tiers:**
- Level 1: 1 bolt, 5 damage
- Level 2: +1 additional bolt (2 total)
- Level 3: +3 damage (8 total)
- Level 4: +2 additional bolts (4 total)

**Stats:**
- Cooldown: 1.5 seconds
- Knockback: 100

## Lightning

**Behavior:** Spawns on a random enemy, then chains to nearby enemies within range.

**Upgrade Tiers:**
- Level 1: 1 target, 5 damage, 1 chain
- Level 2: +1 additional chain (2 chains)
- Level 3: +3 damage (8 total)
- Level 4: +1 additional chain (3 chains total)

**Stats:**
- Cooldown: 2.0 seconds
- Chain range: 150 pixels
- Knockback: 80

## Implementation Components

1. **Attack Scripts** (`Player/Attack/`)
   - `dark_bolt.gd` - instant damage on enemy
   - `lightning.gd` - chain attack between enemies

2. **Attack Scenes** (`Player/Attack/`)
   - `dark_bolt.tscn` - Area2D with AnimatedSprite2D
   - `lightning.tscn` - Area2D with AnimatedSprite2D

3. **Upgrade Definitions** (`Utility/upgrade_db.gd`)
   - darkbolt1-4 entries
   - lightning1-4 entries

4. **Player Integration** (`Player/player.gd`)
   - Preload new attacks
   - Add timer nodes in player.tscn
   - Connect timer signals
   - Add upgrade_character matches

## Dependencies

- Uses existing enemy detection system (`enemy_close` array)
- Uses existing upgrade system (prerequisites, tiers)
- Uses existing HitBox/HurtBox damage system