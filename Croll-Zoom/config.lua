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

-- First-person zoom: ray from head toward camera so it cannot sit past a wall.
Config.FirstPersonForward = 1.0
Config.FirstPersonZOffset = 0.5
-- Meters to keep scripted cam in front of hit geometry (first person).
Config.WallClearance = 0.18
-- Shape test flags for wall probe (map + objects; tune if props block wrongly).
Config.CollisionProbeFlags = 1 | 16 | 256

-- Native keymapping (standalone, no ox_lib).
Config.KeyMapper = 'MOUSE_BUTTON'
Config.KeyZoom = 'MOUSE_MIDDLE'

-- Drop zoom when aiming down sights.
Config.DisableWhenFreeAiming = true

-- Prevent bad interior/console camera in vehicles.
Config.DisallowInVehicle = true

-- Block zoom while in first-person view (on foot). When false, FP zoom uses wall clamp settings below.
Config.DisallowFirstPerson = false

-- Extra hard block: if player is in vehicle and view mode is first person, never zoom.
Config.BlockVehicleFirstPerson = true

-- Server console GitHub version check on resource start (uses repo `version` file).
Config.VersionCheck = true
