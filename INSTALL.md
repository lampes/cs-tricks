# CS-Tricks Installation Guide

## Quick Setup

1. **Download & Extract**
   - Place the `cs-tricks` folder in your FiveM server's `resources` directory

2. **Update Server Config**
   - Add `ensure cs-tricks` to your `server.cfg`

3. **Restart Server**
   - Restart your FiveM server or use `refresh` and `start cs-tricks`

## File Structure
```
cs-tricks/
├── fxmanifest.lua          # Resource manifest
├── config.lua              # Main configuration
├── client/                 # Client-side scripts
│   ├── main.lua           # Core functionality
│   ├── tricks.lua         # Trick mechanics
│   └── ui.lua             # UI management
├── server/                 # Server-side scripts
│   └── main.lua           # Server features
└── html/                   # UI Interface
    ├── index.html         # Main UI
    ├── style.css          # Styling
    └── script.js          # UI JavaScript
```

## Testing the Installation

1. **Join Server** - Connect to your FiveM server
2. **Get a Motorcycle** - Spawn any motorcycle (e.g., `/car akuma`)
3. **Test Controls**:
   - Hold **Left Shift** for wheelie
   - Hold **Left Alt** for stoppie  
   - Press **Space** for flip
   - Press **F5** to toggle UI

4. **Check Commands**:
   - `/trickhelp` - Show help
   - `/trickstats` - Show statistics
   - `/resetstats` - Reset session

## Troubleshooting

**Resource not starting?**
- Check server console for errors
- Ensure all files are present
- Verify `fxmanifest.lua` is correct

**Controls not working?**
- Make sure you're on a motorcycle
- Check speed (minimum 10 km/h)
- Verify keybinds in `config.lua`

**UI not showing?**
- Press F5 to toggle
- Check `Config.UI.ShowScore` in config
- Look for JavaScript errors in F8 console

## Configuration

Edit `config.lua` to customize:
- Keybinds and controls
- Scoring system
- Supported motorcycles
- UI settings

Restart the resource after making changes:
```
refresh
restart cs-tricks
```

## Performance

The script is optimized for performance:
- Only runs when on motorcycles
- Efficient trick detection
- Minimal server load
- Optimized UI updates

For any issues, check the server console and client F8 console for error messages.