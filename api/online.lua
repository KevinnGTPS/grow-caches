-- Ongleng (Online Players System) by Kevin
print("(Loaded) Ongleng by Kevin")

local Roles = {
    PLAYER = 0,
    VIP = 1,
    SUPER_VIP = 2,
    MODERATOR = 3,
    ADMINISTRATOR = 4,
    COMMUNITY_MANAGER = 5,
    CREATOR = 6,
    GOD = 7,
    DEVELOPER = 51
}

local statsCommands = {"ons", "onlines"}
local serverStartTime = os.time()
local cache = {}
local lastCacheUpdateTime = 0
local CACHE_UPDATE_INTERVAL = 1

local function updateStatsCache()
    local onlinePlayers = getServerPlayers()
    local newCache = {
        onlineCount = #onlinePlayers,
        serverName = getServerName(),
        uptime = os.time() - serverStartTime,
        devices = { PC = 0, Android = 0, iOS = 0, Other = 0 },
        countries = {},
        worlds = {},
        playerListStr = ""
    }

    local playerList = {}
    local worldCounts = {}

    for _, p in ipairs(onlinePlayers) do
        local platform = p:getPlatform() or ""
        if platform == "0,1,1" or platform:match("^0,") then 
            newCache.devices.PC = newCache.devices.PC + 1
        elseif platform == "4" then 
            newCache.devices.Android = newCache.devices.Android + 1
        elseif platform == "1" then 
            newCache.devices.iOS = newCache.devices.iOS + 1
        else 
            newCache.devices.Other = newCache.devices.Other + 1 
        end

        local country = p:getCountry()
        if country and country ~= "" then 
            newCache.countries[country] = (newCache.countries[country] or 0) + 1 
        end

        local worldName = p:getWorldName() or "EXIT"
        worldCounts[worldName] = (worldCounts[worldName] or 0) + 1
        
        table.insert(playerList, "`w" .. p:getName())
    end

    local sortedWorlds = {}
    for name, count in pairs(worldCounts) do
        table.insert(sortedWorlds, { name = name, count = count })
    end
    table.sort(sortedWorlds, function(a, b) return a.count > b.count end)
    newCache.worlds = sortedWorlds
    newCache.playerListStr = table.concat(playerList, ", ")

    cache = newCache
    lastCacheUpdateTime = os.time()
end

local function formatUptime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    return hours .. "h " .. minutes .. "m"
end

local function showServerStatsDialog(player)
    local dialog = "set_default_color|\n"
    dialog = dialog .. "set_bg_color|43,34,74,200|\n"
    dialog = dialog .. "set_border_color|112,86,191,255|\n"
    dialog = dialog .. "add_label_with_icon|big|`oServer Statistics|left|3802|\n"
    dialog = dialog .. "add_label_with_icon|medium|`oInfo|left|7190|\n"
    dialog = dialog .. "add_textbox|`oServer: `2" .. cache.serverName .. "|left|\n"
    dialog = dialog .. "add_textbox|`oOnline: `2" .. cache.onlineCount .. "`o/`43,000`o|\n"
    dialog = dialog .. "add_textbox|`o────────────────────────────|\n"
    dialog = dialog .. "add_label_with_icon|medium|`oPlayer Device:|left|572|\n"
    dialog = dialog .. "add_textbox|`oPC Users: `2" .. cache.devices.PC .. "|\n"
    dialog = dialog .. "add_textbox|`oiOS Users: `2" .. cache.devices.iOS .. "|\n"
    dialog = dialog .. "add_textbox|`oAndroid Users: `2" .. cache.devices.Android .. "|\n"
    dialog = dialog .. "add_textbox|`oMacBook Users: `2" .. cache.devices.Other .. "|\n"
    dialog = dialog .. "add_textbox|`oUnknown Device Users: `2" .. cache.devices.Other .. "|\n"
    dialog = dialog .. "add_textbox|`o────────────────────────────|\n"

    local countryList = {}
    for country, count in pairs(cache.countries) do
        table.insert(countryList, country:upper() .. "(`2" .. count .. "`o)")
    end
    dialog = dialog .. "add_textbox|`oPlayer Country: " .. table.concat(countryList, ", ") .. "|\n"

    dialog = dialog .. "add_textbox|`o────────────────────────────|\n"
    dialog = dialog .. "add_textbox|`oPlayers Online: " .. cache.playerListStr .. "|\n"
    dialog = dialog .. "add_quick_exit|\n"
    dialog = dialog .. "end_dialog|ons_stats|||\n"
    player:onDialogRequest(dialog)
end

onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")
    if command then
        for _, cmd in ipairs(statsCommands) do
            if command:lower() == cmd then
                showServerStatsDialog(player)
                return true
            end
        end
    end
    return false
end)

onPlayerDialogCallback(function(world, player, data)
    return false
end)

onTick(function()
    if os.time() - lastCacheUpdateTime > CACHE_UPDATE_INTERVAL then
        updateStatsCache()
    end
end)

updateStatsCache()

function string:title()
    return self:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end
