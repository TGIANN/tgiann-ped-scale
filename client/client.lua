local tick = nil

---@alias BagName string

---@class PlayerHeightWeight
---@field weight number
---@field height number
---@field ply number

---@class HeightWeightState
---@field weight number
---@field height number

---@type table<BagName, PlayerHeightWeight>
local closestPlayer = {}

---@param bagName BagName
local function removePlayerValue(bagName)
    closestPlayer[bagName] = nil
end

---@param vec vector3
local function norm(vec)
    local mag = math.sqrt(vec.x ^ 2 + vec.y ^ 2 + vec.z ^ 2)
    if mag == 0 then return vec end
    return vector3(vec.x / mag, vec.y / mag, vec.z / mag)
end

---@param ped number
---@param heightScale number
---@param widthScale number
local function changeEntitySize(ped, heightScale, widthScale)
    if not DoesEntityExist(ped) then return end
    if IsPedInAnyVehicle(ped, false) then return end -- Set Entity Size does not work properly in vehicles

    local forward, right, upVector, position = GetEntityMatrix(ped)

    local adjustedWidthScale = config.weight.active and heightScale * widthScale or heightScale


    local forwardNorm = norm(forward) * adjustedWidthScale
    local rightNorm   = norm(right) * adjustedWidthScale
    local upNorm      = norm(upVector) * heightScale


    local entitySpeed             = GetEntitySpeed(ped)
    local entityHeightAboveGround = GetEntityHeightAboveGround(ped)

    local adjustedZ               = (entitySpeed <= 0 and entityHeightAboveGround < 2) and (entityHeightAboveGround - heightScale) or (GetEntityUprightValue(ped) - heightScale)

    -- Disable look at the arround to prevent flickering
    TaskLookAtEntity(ped, ped, 1, 2048, 3)

    SetEntityMatrix(ped,
        forwardNorm.x, forwardNorm.y, forwardNorm.z,
        rightNorm.x, rightNorm.y, rightNorm.z,
        upNorm.x, upNorm.y, upNorm.z,
        position.x, position.y, (position.z - adjustedZ)
    )
end

CreateThread(function()
    while true do
        if not tick then
            if next(closestPlayer) then
                tick = SetInterval(function()
                    local playerCoords = GetEntityCoords(cache.ped)
                    for key, data in pairs(closestPlayer) do
                        if NetworkIsPlayerActive(data.ply) and (data.height ~= 1.0 or data.weight ~= 1.0) then
                            local ped = GetPlayerPed(data.ply)
                            if DoesEntityExist(ped) then
                                local distance = #(playerCoords - GetEntityCoords(ped))
                                if distance < 100 then
                                    changeEntitySize(ped, data.height, data.weight)
                                end
                            end
                        else
                            removePlayerValue(key)
                        end
                    end
                end)
            end
        elseif not next(closestPlayer) then
            tick = ClearInterval(tick)
        end
        Wait(1000)
    end
end)

---@param bagName BagName
---@param value HeightWeightState
---@diagnostic disable-next-line:param-type-mismatch
AddStateBagChangeHandler(config.stateName, nil, function(bagName, _, value)
    local ply = GetPlayerFromStateBagName(bagName)
    if not value then return removePlayerValue(bagName) end
    if ply == 0 then return removePlayerValue(bagName) end

    closestPlayer[bagName] = {
        ply    = ply,
        weight = value.weight,
        height = value.height
    }
end)
