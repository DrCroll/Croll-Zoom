Config = {}

-- Master switch for shoulder zoom (scripted cam style).
Config.EnableZoom = true

-- RenderScriptCams blend time in ms (lower = snappier in/out).
Config.EaseMs = 200

-- Scripted cam FOV while zooming (lower = more zoom).
Config.ZoomFov = 22.0

-- Base follow smoothing (0.0-1.0). Lower smooths more and reduces jitter.
Config.BaseFollowLerp = 0.14

-- Snap instantly when camera delta is very large to avoid rubber-band jumps.
Config.SnapDistance = 1.75

-- Native keymapping (standalone, no ox_lib).
Config.KeyMapper = 'MOUSE_BUTTON'
Config.KeyZoom = 'MOUSE_MIDDLE'

-- Drop zoom when aiming down sights.
Config.DisableWhenFreeAiming = true

-- Prevent bad interior/console camera in vehicles.
Config.DisallowInVehicle = true

-- Extra hard block: if player is in vehicle and view mode is first person, never zoom.
Config.BlockVehicleFirstPerson = true
