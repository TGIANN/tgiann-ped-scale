local stateName = config.stateName

local isQb = GetResourceState('qb-core') == 'started'
local isEsx = GetResourceState('es_extended') == 'started'

local frameWork = isQb and exports['qb-core']:GetCoreObject() or isEsx and exports['es_extended']:getSharedObject() or nil

---@param source number
---@return string? # Player identifer
local function getPlayerIdentifier(source)
    if not frameWork then
        return GetPlayerIdentifierByType(tostring(source), 'license') or GetPlayerIdentifierByType(tostring(source), 'license2')
    end

    if isQb then
        local xPlayer = frameWork.Functions.GetPlayer(source)
        if not xPlayer then return end
        return xPlayer.PlayerData.citizenid
    elseif isEsx then
        local xPlayer = frameWork.GetPlayerFromId(source)
        if not xPlayer then return end
        return xPlayer.identifier
    end
end

---@param source number
---@param weight number
---@param height number
local function updateSql(source, weight, height)
    local identifier = getPlayerIdentifier(source)
    if not identifier then return end

    local query = "INSERT INTO `tgiann_ped_scale` (`weight`, `height`, `player`) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE `weight` = VALUES(`weight`), `height` = VALUES(`height`)"
    MySQL.update(query, { weight, height, identifier })
end

---@param source number
---@return HeightWeightState
local function getPlayerHeightWeight(source)
    local query = "SELECT `weight`, `height` FROM `tgiann_ped_scale` WHERE `player` = ?"
    local result = MySQL.single.await(query, { getPlayerIdentifier(source) })
    return result and { weight = result.weight, height = result.height } or { weight = 1.0, height = 1.0 }
end

---@param source number
---@param value number
---@param valueType "height" | "weight"
---@return boolean # true if valid, false if invalid
---@return string? # error message if invalid
local function checkCommand(source, value, valueType)
    local configData = config[valueType]
    assert(configData, "Invalid config data for " .. valueType)

    if not source or source <= 0 then
        return false, LANG.COMMAND_WRONG_PLAYER_ID
    end

    if not value then
        return false, LANG.COMMAND_WRONG_VALUE
    end

    if configData.min and value < configData.min then
        return false, string.format(LANG.COMMAND_VALUE_MIN, valueType, configData.min)
    end

    if configData.max and value > configData.max then
        return false, string.format(LANG.COMMAND_VALUE_MAX, valueType, configData.max)
    end

    return true
end

---@param source number
---@param weight? number
---@param height? number
---@param update? boolean
local function setHeightWeight(source, weight, height, update)
    if GetPlayerPing(tostring(source)) <= 0 then
        return false, LANG.COMMAND_WRONG_PLAYER_ID
    end

    local player = Player(source).state
    weight = weight and weight or player[stateName]?.weight or 1.0
    height = height and height or player[stateName]?.height or 1.0

    ---@type HeightWeightState
    local stateValue = { weight = weight, height = height }

    if weight ~= 1.0 or height ~= 1.0 then
        player:set(stateName, stateValue, true)
    else
        player:set(stateName, nil, true)
    end

    if update then updateSql(source, weight, height) end
end

---@param source number
local function loadPlayerHeightWeight(source)
    local result = getPlayerHeightWeight(source)
    setHeightWeight(source, result.weight, result.height)
end

if config.height.active then
    lib.addCommand(config.commands.setHeight.command, {
        help = LANG.COMMAND_SET_HEIGHT,
        restricted = config.commands.setHeight.permission or "group.admin",
        params = {
            {
                name = 'playerid',
                type = 'playerId',
                help = 'Target player\'s server id',
            },
            {
                name = 'height',
                type = 'number',
                help = 'height',
            },
        },
    }, function(source, args)
        local success1, errorMsg1 = checkCommand(args.playerid, args.height, "height")
        if not success1 then
            ---@diagnostic disable-next-line: param-type-mismatch
            return Notify(source, errorMsg1)
        end

        local success2, errorMsg2 = setHeightWeight(args.playerid, nil, args.height, true)
        if not success2 then
            return Notify(source, errorMsg2)
        end
        Notify(source, string.format(LANG.COMMAND_SET_HEIGHT_SUCCESS, args.height))
    end)
end

if config.weight.active then
    lib.addCommand(config.commands.setWeight.command, {
        help = LANG.COMMAND_SET_WEIGHT,
        restricted = config.commands.setWeight.permission or "group.admin",
        params = {
            {
                name = 'playerid',
                type = 'playerId',
                help = 'Target player\'s server id',
            },
            {
                name = 'weight',
                type = 'number',
                help = 'Weight',
            },
        },
    }, function(source, args)
        local success1, errorMsg1 = checkCommand(args.playerid, args.weight, "weight")
        if not success1 then
            ---@diagnostic disable-next-line: param-type-mismatch
            return Notify(source, errorMsg1)
        end

        local success2, errorMsg2 = setHeightWeight(args.playerid, args.weight, nil, true)
        if not success2 then
            return Notify(source, errorMsg2)
        end

        Notify(source, string.format(LANG.COMMAND_SET_WEIGHT_SUCCESS, args.weight))
    end)
end

-- Reset height and weight for all players when the resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, playerId in ipairs(GetPlayers()) do
        Player(playerId).state:set(stateName, nil, true)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SetTimeout(1000, function()
        for _, playerId in ipairs(GetPlayers()) do
            ---@diagnostic disable-next-line: param-type-mismatch
            loadPlayerHeightWeight(tonumber(playerId))
        end
    end)
end)

if isQb then
    AddEventHandler('QBCore:Server:PlayerLoaded', function(xPlayer)
        loadPlayerHeightWeight(xPlayer.PlayerData.source)
    end)
elseif isEsx then
    AddEventHandler('esx:playerLoaded', function(playerId)
        loadPlayerHeightWeight(playerId)
    end)
else
    AddEventHandler('playerJoining', function(playerId)
        loadPlayerHeightWeight(playerId)
    end)
end
