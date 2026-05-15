if not Config.EnableZoom then return end

local EaseMs = math.max(0, tonumber(Config.EaseMs) or 200)
local ZoomFov = math.max(1.0, math.min(130.0, tonumber(Config.ZoomFov) or 22.0))
local BaseFollowLerp = math.max(0.01, math.min(1.0, tonumber(Config.BaseFollowLerp) or 0.14))
local SnapDistance = math.max(0.1, tonumber(Config.SnapDistance) or 1.75)

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpAngle(a, b, t)
    local diff = ((b - a + 180.0) % 360.0) - 180.0
    return a + diff * t
end

local function frameLerpAlpha(base)
    local dt = GetFrameTime()
    if dt <= 0.0 then return base end
    return 1.0 - (1.0 - base) ^ (dt * 60.0)
end

local zoom = {
    active = false,
    cam = nil,
    block = false,
    held = false,
    scriptCamsOn = false,
}

local function isGameplayReady()
    if not NetworkIsSessionStarted() then return false end
    if IsPlayerSwitchInProgress() then return false end
    if IsScreenFadedOut() or IsScreenFadingOut() or IsScreenFadingIn() then return false end
    if IsCutsceneActive() then return false end
    if LocalPlayer and LocalPlayer.state then
        local isLoggedIn = LocalPlayer.state.isLoggedIn
        if isLoggedIn ~= nil and not isLoggedIn then
            return false
        end
    end
    return true
end

local function mayUseZoom()
    if zoom.block then return false end
    if not isGameplayReady() then return false end
    if IsPauseMenuActive() then return false end
    local ped = PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) or IsEntityDead(ped) then return false end
    if Config.DisallowInVehicle and IsPedInAnyVehicle(ped, false) then return false end
    if Config.BlockVehicleFirstPerson and IsPedInAnyVehicle(ped, false) and GetFollowPedCamViewMode() == 4 then return false end
    if IsPedRagdoll(ped) then return false end
    if Config.DisableWhenFreeAiming and IsPlayerFreeAiming(PlayerId()) then return false end
    return true
end

local function getFollowTarget()
    local ped = PlayerPedId()
    local mode = GetFollowPedCamViewMode()
    if mode == 4 then
        local coords = GetEntityCoords(ped) + (GetEntityForwardVector(ped) * 1.0)
        return vector3(coords.x, coords.y, coords.z + 0.5), GetGameplayCamRot(2)
    end
    return GetGameplayCamCoord(), GetGameplayCamRot(2)
end

local function forceGameplayCamera()
    if zoom.scriptCamsOn then
        RenderScriptCams(false, false, 0, true, true)
        zoom.scriptCamsOn = false
    end
end

local function createCamera()
    local coords, rotation = getFollowTarget()
    local cam = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        coords.x, coords.y, coords.z,
        rotation.x, rotation.y, rotation.z,
        ZoomFov,
        true,
        2
    )
    if not cam or cam == 0 or not DoesCamExist(cam) then
        return false
    end
    zoom.cam = cam
    return true
end

local function disableZoom()
    zoom.active = false

    if type(zoom.cam) == 'number' and DoesCamExist(zoom.cam) then
        ---@type integer
        local cam = zoom.cam
        local mode = GetFollowPedCamViewMode()
        zoom.cam = nil
        SetCamActive(cam, false)
        RenderScriptCams(false, true, mode == 4 and 0 or EaseMs, true, true)
        zoom.scriptCamsOn = false
        DestroyCam(cam, true)
    else
        zoom.cam = nil
        forceGameplayCamera()
    end
end

local function enableZoom()
    if not mayUseZoom() then return end
    if not zoom.cam and not createCamera() then
        zoom.active = false
        return
    end
    if not zoom.cam or not DoesCamExist(zoom.cam) then
        zoom.cam = nil
        zoom.active = false
        return
    end
    zoom.active = true
    SetCamFov(zoom.cam, ZoomFov)
    SetCamActive(zoom.cam, true)
    RenderScriptCams(true, true, EaseMs, true, true)
    zoom.scriptCamsOn = true
end

exports('blockZoom', function(block)
    zoom.block = block and true or false
    if zoom.block then
        disableZoom()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    zoom.held = false
    disableZoom()
end)

RegisterCommand('+croll_zoom_shoulder', function()
    if not Config.EnableZoom then return end
    zoom.held = true
end, false)

RegisterCommand('-croll_zoom_shoulder', function()
    zoom.held = false
    if zoom.active then
        disableZoom()
    end
end, false)

RegisterKeyMapping('+croll_zoom_shoulder', 'Hold shoulder cam zoom (Croll)', Config.KeyMapper, Config.KeyZoom)

CreateThread(function()
    local prevCoords = GetGameplayCamCoord()
    local prevRot = GetGameplayCamRot(2)

    while true do
        if zoom.held and not zoom.active then
            if mayUseZoom() then
                enableZoom()
                if zoom.active and zoom.cam then
                    prevCoords, prevRot = getFollowTarget()
                end
            end
        elseif zoom.active and (not zoom.held or not mayUseZoom()) then
            disableZoom()
        end

        local cam = zoom.cam
        if zoom.active and cam and DoesCamExist(cam) then
            local targetCoords, rotation = getFollowTarget()
            local dist = #(targetCoords - prevCoords)
            local alpha = frameLerpAlpha(BaseFollowLerp)
            if dist > SnapDistance then
                alpha = 1.0
            end

            local smoothCoords = vector3(
                lerp(prevCoords.x, targetCoords.x, alpha),
                lerp(prevCoords.y, targetCoords.y, alpha),
                lerp(prevCoords.z, targetCoords.z, alpha)
            )
            -- Roll (Y) is not smoothed; it often spikes and causes visible jitter.
            local smoothRot = vector3(
                lerpAngle(prevRot.x, rotation.x, alpha),
                rotation.y,
                lerpAngle(prevRot.z, rotation.z, alpha)
            )

            SetCamCoord(cam, smoothCoords.x, smoothCoords.y, smoothCoords.z)
            SetCamRot(cam, smoothRot.x, smoothRot.y, smoothRot.z, 2)
            SetCamFov(cam, ZoomFov)

            prevCoords = smoothCoords
            prevRot = smoothRot
            Wait(0)
        else
            if zoom.active or zoom.scriptCamsOn then
                disableZoom()
            end
            Wait(50)
        end
    end
end)
