local ESX = exports[Config.Base]:getSharedObject()

function IsAdminOrHigher(player)
    local steamIdentifier = GetPlayerIdentifiers(player.source)[1]
    if steamIdentifier then
        for _, hex in ipairs(Config.authorizedHexids) do
            if hex == steamIdentifier then
                return true
            end
        end
    end
    return false
end

function generateRandomPlate()
    local letters = ""
    for i = 1, Config.PlateLetters do
        letters = letters .. string.char(math.random(65, 90))
    end

    local numbers = ""
    for i = 1, Config.PlateNumbers do
        numbers = numbers .. tostring(math.random(0, 9))
    end

    if Config.PlateUseSpace then
        return letters .. " " .. numbers
    else
        return letters .. numbers
    end
end

RegisterCommand('geimport', function(source, args)
    local player = ESX.GetPlayerFromId(source)

    if IsAdminOrHigher(player) then
        local targetId = tonumber(args[1])
        local vehicleName = args[2]
        local targetPlayer = ESX.GetPlayerFromId(targetId)

        if targetPlayer then
            local plate = generateRandomPlate()
            local vehicleProps = {
                plate = plate,
                model = vehicleName
            }

            local insertQuery = string.format('INSERT INTO %s (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', Config.DatabaseVehicle)

            MySQL.Async.execute(insertQuery, {
                ['@owner']   = targetPlayer.characterId,
                ['@plate']   = plate,
                ['@vehicle'] = json.encode(vehicleProps)
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    exports[Config.Keysystem]:AddKey(targetPlayer, {
                        ["keyName"] = plate,
                        ["keyUnit"] = plate,
                        ["label"] = plate,
                        ["type"] = "vehicle"
                    })

                    local notifyMessage = string.format(Config.Notify["fickbilen"], plate, player.getName())
                    TriggerClientEvent('esx:showNotification', targetId, notifyMessage)

                    -- Log the event to Discord
                    local discord_webhook = Config.Webhook
                    if discord_webhook and discord_webhook ~= "" then
                        PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode({
                            username = "wT/development",
                            embeds = {{
                                ["color"] = 800080,  -- Green color
                                ["title"] = "Kommando som används: /geimport",
                                ["description"] = ("Spelaren **%s** (ID: %s) gav bilen **%s** med registreringsnummret **%s** till spelaren **%s**"):format(player.getName(), source, vehicleName, plate, targetPlayer.getName()),
                                ["footer"] = {
                                    ["text"] = os.date("%Y-%m-%d %H:%M:%S"),
                                }
                            }}
                        }), { ['Content-Type'] = 'application/json' })
                    else
                        print("[ERROR] Webhook URL is missing in config.lua")
                    end

                else
                    TriggerClientEvent('esx:showNotification', source, Config.Notify["nagotgickfel"], "error")
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, Config.Notify["Spelarenfinnsinte"], "error")
        end
    else
        TriggerClientEvent('esx:showNotification', source, Config.Notify["inteperms"], "error")
    end
end, false)
