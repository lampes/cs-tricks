# CS-Tricks - FiveM Motorcycle Tricks Script

A comprehensive FiveM motorcycle tricks system inspired by kc tricks, featuring advanced trick detection, scoring system, and beautiful UI.

## Features

🏍️ **Motorcycle Trick System**
- Wheelies (hold Left Shift)
- Stoppies (hold Left Alt) 
- Flips (press Space)
- Natural trick detection
- Combo system with multipliers

🎯 **Scoring System**
- Base points for tricks
- Duration bonuses for sustained tricks
- Speed bonuses for high-speed tricks
- Perfect trick bonuses for long tricks
- Combo multipliers (up to 3x)

🎨 **Beautiful UI**
- Real-time score display
- Trick notifications with animations
- Combo indicators
- Perfect trick celebrations
- Responsive design

📊 **Statistics & Leaderboards**
- Session and total score tracking
- Detailed trick statistics
- Achievement system
- Server-side leaderboards
- Player stats persistence

## Installation

1. Download the resource and place it in your `resources` folder
2. Add `ensure cs-tricks` to your `server.cfg`
3. Restart your server

## Controls

| Key | Action |
|-----|--------|
| **Left Shift** | Hold for Wheelie |
| **Left Alt** | Hold for Stoppie |
| **Space** | Perform Flip |
| **F5** | Toggle UI |

## Commands

| Command | Description |
|---------|-------------|
| `/trickstats` | Show current statistics |
| `/tricktop` | Show best trick this session |
| `/resetstats` | Reset session statistics |
| `/trickhelp` | Show help information |

## Configuration

Edit `config.lua` to customize:

- **Keybinds**: Change control keys
- **Trick Settings**: Adjust minimum speed, scoring, combo timeouts
- **Motorcycle Models**: Add/remove supported bikes
- **Scoring System**: Modify points and multipliers
- **UI Settings**: Toggle elements and positioning

## Supported Motorcycles

The script supports all GTA V motorcycles including:
- Sport bikes (Akuma, Bati, FCR, etc.)
- Cruisers (Bagger, Sovereign, etc.) 
- Off-road bikes (Sanchez, Enduro, etc.)
- Custom motorcycles

## Scoring Breakdown

### Base Scores
- **Wheelie**: 10 points + 5 per second
- **Stoppie**: 15 points + 7 per second  
- **Flip**: 50-100 points depending on type

### Bonuses
- **Perfect Trick**: +50-60 points for sustained tricks
- **Speed Bonus**: 1.2x multiplier above 80 km/h
- **Combo Multiplier**: Up to 3x for chaining tricks

### Example Scoring
- 5-second wheelie at high speed with 3x combo: `(10 + 25) × 1.2 × 3 = 126 points`

## Development

### File Structure
```
cs-tricks/
├── fxmanifest.lua          # Resource manifest
├── config.lua              # Configuration settings
├── client/
│   ├── main.lua            # Core client logic
│   ├── tricks.lua          # Trick detection & mechanics
│   └── ui.lua              # UI management
├── server/
│   └── main.lua            # Server-side features
└── html/
    ├── index.html          # UI interface
    ├── style.css           # UI styling
    └── script.js           # UI JavaScript
```

### Events

**Client Events:**
- `cs-tricks:trickStarted` - Trick begins
- `cs-tricks:trickCompleted` - Trick ends with score
- `cs-tricks:scoreUpdate` - Score changes
- `cs-tricks:achievementUnlocked` - New achievement

**Server Events:**  
- `cs-tricks:updateServerScore` - Update server stats
- `cs-tricks:getLeaderboard` - Request leaderboard
- `cs-tricks:getPlayerStats` - Request player stats

## Customization

### Adding New Motorcycles
Add model hashes to `Config.MotorcycleModels` in `config.lua`:

```lua
Config.MotorcycleModels = {
    `newbike1`,
    `newbike2`,
    -- existing bikes...
}
```

### Modifying Scoring
Adjust values in `Config.Scores`:

```lua
Config.Scores = {
    Wheelie = {
        base = 15,        -- Base points
        perSecond = 8,    -- Points per second
        perfect = 75,     -- Perfect bonus
    },
}
```

### Custom Keybinds
Change controls in `Config.Keys`:

```lua
Config.Keys = {
    Wheelie = {0, 21},    -- {control_group, control_id}
    Stoppie = {0, 19},
    Flip = {0, 22},
}
```

## Troubleshooting

**Tricks not working?**
- Ensure you're on a supported motorcycle
- Check minimum speed requirement (10 km/h by default)
- Verify keybinds in config

**UI not showing?**
- Press F5 to toggle UI
- Check `Config.UI.ShowScore` setting
- Ensure resource is started properly

**No scores saving?**
- Server-side features require proper setup
- Check server console for errors

## Credits

- Inspired by the original kc tricks system
- Built for FiveM using Lua and NUI
- Created with ❤️ for the FiveM community

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, suggestions, or contributions, please create an issue on the repository.
