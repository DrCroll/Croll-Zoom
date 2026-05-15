## Croll-Zoom - discord.gg/DBqCZjZ8VN

Standalone **FiveM** client resource: hold a key (default **middle mouse**) to switch to a **scripted follow camera** with a tighter **field of view**, smoothed each frame so movement stays stable and less jumpy.

No framework, no bridge, no `ox_lib` requirement.

## Features

- **Hold-to-zoom** via native `RegisterKeyMapping` (reliable hold / release; avoids “stuck” keybind edge cases)
- **Smoothed** camera follow with optional **snap** on huge position jumps (teleports / large deltas)
- **Safety guards**: pause menu, death, ragdoll, optional block while **ADS**
- **Vehicle defaults**: zoom disabled in vehicles by default to avoid bad interior / first-person cockpit camera
- **`exports('blockZoom', ...)`** so other resources can temporarily disable zoom

## Installation

1. Copy the `Croll-Zoom` folder into your server `resources` directory.
2. Add to `server.cfg`:

   ```
   ensure Croll-Zoom
   ```

3. Restart the server or run `ensure Croll-Zoom` / `restart Croll-Zoom` in the server console.

## Default controls

By default the bind uses FiveM’s input mapping:

- **Mapper**: `MOUSE_BUTTON`
- **Parameter**: `MOUSE_MIDDLE`

Players can rebind it in GTA **Settings → Key Bindings → FiveM** (look for **Hold shoulder cam zoom (Croll)**).

## Configuration

Edit `config.lua`:

| Option | Description |
|--------|-------------|
| `Config.EnableZoom` | Master on/off |
| `Config.EaseMs` | Blend time for `RenderScriptCams` in/out (ms) |
| `Config.ZoomFov` | Scripted camera FOV while zooming (lower = more zoom) |
| `Config.BaseFollowLerp` | Follow smoothing (0.0–1.0); lower = smoother, less jitter |
| `Config.SnapDistance` | If target camera jumps farther than this (meters), snap instead of smooth |
| `Config.KeyMapper` / `Config.KeyZoom` | Default key mapping strings |
| `Config.DisableWhenFreeAiming` | End zoom while aiming down sights |
| `Config.DisallowInVehicle` | Block zoom while in any vehicle |
| `Config.BlockVehicleFirstPerson` | Extra block when in vehicle **and** first-person view mode |
| `Config.VersionCheck` | On server start, compare local version to [GitHub `version` file](https://github.com/DrCroll/Croll-Zoom) |

## Version updates

On resource start the server prints whether **Croll-Zoom** is up to date. Keep the root `version` file on GitHub in sync with `fxmanifest.lua` (`version 'x.y.z'`).

Set `Config.VersionCheck = false` to disable the HTTP check.

## Export

Other resources can block zoom (for menus, cutscenes, minigames, etc.):

```lua
exports['Croll-Zoom']:blockZoom(true)  -- disable
exports['Croll-Zoom']:blockZoom(false) -- allow again
```

## License

Specify your license in this repository (for example MIT / GPL) if you distribute the script publicly.
