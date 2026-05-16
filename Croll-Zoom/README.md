## Croll-Zoom - discord.gg/DBqCZjZ8VN

Standalone **FiveM** client resource: hold a key (default **middle mouse**) to switch to a **scripted follow camera** with a tighter **field of view**, smoothed each frame so movement stays stable and less jumpy.

No framework, no bridge, no `ox_lib` requirement.

## Features

- **Hold-to-zoom** via native `RegisterKeyMapping` (reliable hold / release; avoids “stuck” keybind edge cases)
- **Smoothed** camera follow with optional **snap** on huge position jumps (teleports / large deltas)
- **Safety guards**: pause menu, death, ragdoll, optional block while **ADS**
- **First-person wall clamp**: ray from head toward the zoom point so the cam cannot sit past a wall when hugging geometry
- **`exports('blockZoom', ...)`** so other resources can temporarily disable zoom

## Installation

The [GitHub repo](https://github.com/DrCroll/Croll-Zoom) uses a nested layout (same as [Croll-Ammo](https://github.com/DrCroll/Croll-Ammo)):

- **Repo root** — overview README only  
- **[`Croll-Zoom/`](https://github.com/DrCroll/Croll-Zoom/tree/main/Croll-Zoom)** — the actual FiveM resource (`fxmanifest.lua`, `client/`, `server/`, etc.)

Use the **inner** folder on your server, not the repository root.

1. Download the [latest release](https://github.com/DrCroll/Croll-Zoom/releases) **or** copy the inner [`Croll-Zoom`](https://github.com/DrCroll/Croll-Zoom/tree/main/Croll-Zoom) folder into your server `resources` directory.
2. Add to `server.cfg`:

   ```
   ensure Croll-Zoom
   ```

3. Restart the server or run `ensure Croll-Zoom` / `restart Croll-Zoom` in the server console.

Your `resources` path should look like:

```
resources/
  Croll-Zoom/
    fxmanifest.lua
    config.lua
    client/
    server/
    version
```

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
| `Config.FirstPersonForward` | First-person: how far ahead of the ped the zoom target sits (meters) |
| `Config.FirstPersonZOffset` | First-person: vertical offset on that target (meters) |
| `Config.WallClearance` | First-person: keep scripted cam this far in front of hit geometry |
| `Config.CollisionProbeFlags` | Raycast flags for wall probe (bitmask; change if thin props block wrongly) |
| `Config.KeyMapper` / `Config.KeyZoom` | Default key mapping strings |
| `Config.DisableWhenFreeAiming` | End zoom while aiming down sights |
| `Config.DisallowInVehicle` | Block zoom while in any vehicle |
| `Config.DisallowFirstPerson` | Block zoom while in first-person view (on foot) |
| `Config.BlockVehicleFirstPerson` | Extra block when in vehicle **and** first-person view mode |
| `Config.VersionCheck` | On server start, compare local version to GitHub |
| `Config.VersionUrl` | Optional override for the raw `version` file URL |

## Version updates

On resource start the server fetches:

`https://raw.githubusercontent.com/DrCroll/Croll-Zoom/main/Croll-Zoom/version`

Keep that file in sync with `fxmanifest.lua` (`version 'x.y.z'`). See [`Croll-Zoom/version`](https://github.com/DrCroll/Croll-Zoom/blob/main/Croll-Zoom/version) on GitHub.

Set `Config.VersionCheck = false` to disable the HTTP check.

## Export

Other resources can block zoom (for menus, cutscenes, minigames, etc.):

```lua
exports['Croll-Zoom']:blockZoom(true)  -- disable
exports['Croll-Zoom']:blockZoom(false) -- allow again
```

## License

Specify your license in this repository (for example MIT / GPL) if you distribute the script publicly.
