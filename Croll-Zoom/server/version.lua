local version = (GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '0.0.0'):gsub('%s+', '')
-- Same layout as Croll-Ammo: version file lives under the resource folder in the repo.
local versionUrl = Config.VersionUrl or 'https://raw.githubusercontent.com/DrCroll/Croll-Zoom/main/Croll-Zoom/version'

CreateThread(function()
    if Config.VersionCheck == false then return end

    PerformHttpRequest(versionUrl, function(code, body)
        if code ~= 200 or not body then
            print(('^3[Croll-Zoom]^0 Version check skipped (HTTP %s). URL: %s'):format(tostring(code), versionUrl))
            return
        end

        local latest = body:gsub('%s+', '')
        if latest == '' then
            return
        end

        if version ~= latest then
            print('^1----------------------| Croll-Zoom |---------------------')
            print('            ^0New version available [^1' .. latest .. '^0]')
            print('     ^5https://github.com/DrCroll/Croll-Zoom')
            print('^1----------------------| Croll-Zoom |---------------------^0')
        else
            print('^2[Croll-Zoom]^0 Up to date (^0' .. version .. '^2).')
        end
    end, 'GET')
end)
