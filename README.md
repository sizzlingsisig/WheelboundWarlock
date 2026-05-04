# Kalbo vs the World

A Vampire Survivors-style survival game built in Godot 4.

## Game Description

Survive waves of enemies, collect experience gems, level up, and defeat the boss to win! Choose from multiple weapons and upgrades to build your character.

## Mechanical Twist

**Manual Attack Control** - Unlike traditional Vampire Survivors where weapons fire automatically, this game requires the player to manually trigger each weapon attack. This creates a unique gameplay experience where the player must actively manage attack timing while dodging enemies.

### How It Works
- Each weapon has its own key binding
- Player must press the correct key to fire each weapon
- Strategic timing and positioning become crucial
- Creates a more action-oriented experience

## Controls

| Action | Input |
|--------|-------|
| Move to target | Right Mouse Click |
| Pause/Menu | ESC |
| Ice Spear | 1 |
| Tornado | 2 |
| Immolate | 3 |
| Lightning | 4 |

## Features

### Weapons (7 total)
- **Ice Spear** - Projectile that seeks enemies
- **Tornado** - Area of effect damage around player
- **Javelin** - Orbiting javelin that attacks automatically
- **Lightning** - Strikes nearest enemy with chains
- **Immolate** - Fire aura that damages on contact
- **Hollow Purple** - Persistent damage zone around player
- **Will O Whisps** - Rotating orbs that damage on contact

### Enemy Types
- Kobold (Weak) - Basic enemy
- Kobold (Strong) - More HP, more damage
- Juggernaut - Tanky, slow
- Cyclops - Large, high damage
- Alien (Boss) - Final boss with multiple attack patterns

### Boss Abilities
- Charge Attack - Dashes at player
- Projectile Burst - 8 radial projectiles
- Ground Slam - AOE damage with warning
- Teleport - Teleports behind player
- Minion Spawn - Summons weak enemies
- Enrage Mode - At 50% HP, attacks become faster

### Systems
- XP and Leveling with upgrade selection
- Object pooling for enemies and projectiles
- Data-driven weapon configuration
- Signal-driven architecture
- FSM-based game states (Menu, Playing, Upgrade, Win/Lose)

## Architecture

This project demonstrates professional game architecture:
- **Composition over inheritance** in weapon system
- **Object pooling** for high-frequency entities (enemies, projectiles)
- **Hierarchical FSM** for game state and enemy behavior
- **Data-driven design** via Resource-based configurations
- **Signal-driven communication** between systems

## Known Issues / Limitations

- Projectile pooling not fully implemented (weapons spawn new instances)
- No save/load system
- Single difficulty (no easy/hard mode)
- Game timer is 5 minutes (shorter than typical Vampire Survivors)
- Some visual placeholders exist

## Tech Stack

- Godot 4.x
- GDScript

## How to Run

1. Open the project in Godot 4
2. Press F5 or click Play to run
3. Select "Play" from the main menu

## Credits

See CREDITS.md for full asset attribution.