if not Config.EnableZoom then return end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpAngle(a, b, t)
    local diff = ((b - a + 180.0) % 360.0) - 180.0
    return a + diff * t
end

local zoom = {
    active = false,
    cam = nil,
    block = false,
    held = false,
}

local function mayUseZoom()
    if zoom.block then return false end
    if IsPauseMenuActive() then return false end
    local ped = PlayerPedId()
    if not ped or ped == 0 or IsEntityDead(ped) then return false end
    if Config.DisallowInVehicle and IsPedInAnyVehicle(ped, false) then return false end
    if Config.BlockVehicleFirstPerson and IsPedInAnyVehicle(ped, false) and GetFollowPedCamViewMode() == 4 then return false end
    if IsPedRagdoll(ped) then return false end
    if Config.DisableWhenFreeAiming and IsPlayerFreeAiming(PlayerId()) then return false end
    return true
end

local function createCamera()
    local ped = PlayerPedId()
    local rotation = GetGameplayCamRot(2)
    local mode = GetFollowPedCamViewMode()
    local coords
    if mode == 4 then
        coords = GetEntityCoords(ped) + (GetEntityForwardVector(ped) * 1.0)
    else
        coords = GetGameplayCamCoord()
    end
    local z = mode == 4 and (coords.z + 0.5) or coords.z
    zoom.cam = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        coords.x, coords.y, z,
        rotation.x, rotation.y, rotation.z,
        Config.ZoomFov,
        true,
        2
    )
end

local function disableZoom()
    zoom.active = false
    if type(zoom.cam) ~= 'number' then
        zoom.cam = nil
        return
    end
    ---@type integer
    local cam = zoom.cam
    local mode = GetFollowPedCamViewMode()
    zoom.cam = nil
    SetCamActive(cam, false)
    RenderScriptCams(false, true, mode == 4 and 0 or Config.EaseMs, true, true)
    DestroyCam(cam, true)
end

local function enableZoom()
    if not mayUseZoom() then return end
    zoom.active = true
    if not zoom.cam then
        createCamera()
    end
    SetCamFov(zoom.cam, Config.ZoomFov)
    SetCamActive(zoom.cam, true)
    RenderScriptCams(true, true, Config.EaseMs, true, true)
end

exports('blockZoom', function(block)
    zoom.block = block and true or false
    if zoom.block and zoom.active then
        disableZoom()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if zoom.cam then
        SetCamActive(zoom.cam, false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(zoom.cam, true)
        zoom.cam = nil
    end
    zoom.active = false
end)

RegisterCommand('+croll_zoom_shoulder', function()
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
                prevCoords = GetGameplayCamCoord()
                prevRot = GetGameplayCamRot(2)
            end
        elseif zoom.active and (not zoom.held or not mayUseZoom()) then
            disableZoom()
        end

        if zoom.active and zoom.cam then
            local ped = PlayerPedId()
            local rotation = GetGameplayCamRot(2)
            local mode = GetFollowPedCamViewMode()
            local coords
            if mode == 4 then
                coords = GetEntityCoords(ped) + (GetEntityForwardVector(ped) * 1.0)
            else
                coords = GetGameplayCamCoord()
            end

            local targetZ = mode == 4 and (coords.z + 0.5) or coords.z
            local targetCoords = vector3(coords.x, coords.y, targetZ)
            local dist = #(targetCoords - prevCoords)
            local alpha = Config.BaseFollowLerp
            if dist > Config.SnapDistance then
                alpha = 1.0
            end

            local smoothCoords = vector3(
                lerp(prevCoords.x, targetCoords.x, alpha),
                lerp(prevCoords.y, targetCoords.y, alpha),
                lerp(prevCoords.z, targetCoords.z, alpha)
            )
            local smoothRot = vector3(
                lerpAngle(prevRot.x, rotation.x, alpha),
                lerpAngle(prevRot.y, rotation.y, alpha),
                lerpAngle(prevRot.z, rotation.z, alpha)
            )

            SetCamCoord(zoom.cam, smoothCoords.x, smoothCoords.y, smoothCoords.z)
            SetCamRot(zoom.cam, smoothRot.x, smoothRot.y, smoothRot.z, 2)
            SetCamFov(zoom.cam, Config.ZoomFov)

            prevCoords = smoothCoords
            prevRot = smoothRot
            Wait(0)
        else
            Wait(50)
        end
    end
end)
