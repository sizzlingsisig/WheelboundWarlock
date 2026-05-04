# Wheelbound Warlock: Person with this ability

A Vampire Survivors-style survival game built in Godot 4.

## Game Description

Survive waves of supernatural enemies, collect arcane essences, and master forbidden magic to defeat the Ancient Warlock! Choose from multiple spells and upgrades to forge your magical destiny.

## Mechanical Twist

**Manual Spell Casting** - Unlike traditional Vampire Survivors where weapons fire automatically, this game requires the player to manually trigger each spell attack. This creates a unique gameplay experience where the player must actively manage spell timing while dodging enemies.

### How It Works
- Each spell has its own key binding
- Player must press the correct key to cast each spell
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

### Weapons
- **Ice Spear** - Projectile that seeks enemies
- **Tornado** - Area of effect damage around player
- **Javelin** - Orbiting javelin that attacks enemies
- **Lightning** - Strikes nearest enemy with chains
- **Immolate** - Fire aura that damages on contact
- **Hollow Purple** - Persistent damage zone around player
- **Will O Whisps** - Rotating orbs that damage on contact

### Enemy Types
- Kobold (Weak) - Basic enemy
- Kobold (Strong) - More HP, more damage
- Juggernaut - Tanky, slow
- Cyclops - Large, high damage
- Giant Amoeba (Boss) - Final boss with multiple attack patterns

### Boss Abilities
- Charge Attack - Dashes at player
- Teleport - Teleports behind player
- Slam - Close-range damage attack

### Systems
- XP and Leveling with upgrade selection
- Object pooling for enemies
- Data-driven weapon configuration
- Signal-driven architecture
- FSM-based game states (Menu, Playing, Upgrade, Win/Lose)

## How to Run

1. Open the project in Godot 4
2. Press F5 or click Play to run
3. Select "Play" from the main menu

## Tech Stack

- Godot 4.x
- GDScript

## Known Issues / Limitations

- No save/load system
- Single difficulty (no easy/hard mode)
- Game timer is 5 minutes (shorter than typical Vampire Survivors)
- Some visual placeholders exist

## Architecture

This project demonstrates professional game architecture:
- Composition over inheritance in weapon system
- Object pooling for high-frequency entities (enemies, projectiles)
- Hierarchical FSM for game state and enemy behavior
- Data-driven design via Resource-based configurations
- Signal-driven communication between systems

## Credits

See CREDITS.md for full asset attribution.