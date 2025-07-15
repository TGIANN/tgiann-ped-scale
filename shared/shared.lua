LANG = setmetatable(config.langs[config.lang], {
    __index = function(object, k)
        local value = rawget(object, k)
        if value == nil then
            local text = string.format("[%s] %s", k, "Missing translation")
            pcall(function() assert(false, text) end)
            rawset(object, k, text)
            return text
        end
        return value
    end
})

if IsDuplicityVersion() then
    ---@param src number
    ---@param msg string
    ---@param notifType? "error" | "success" | "warning" | "info"
    ---@param time? number
    function Notify(src, msg, notifType, time)
        TriggerClientEvent("tgiann-ped-scale:notify", src, msg, notifType, time)
    end
else
    ---@param msg string
    ---@param notifType? "error" | "success" | "warning" | "info"
    ---@param time? number
    function Notify(msg, notifType, time)
        lib.notify({
            title = msg,
            type = notifType or "info",
            position = "top-right",
            duration = time or 5000
        })
    end

    RegisterNetEvent("tgiann-ped-scale:notify", Notify)
end
