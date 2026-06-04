-- Personen
RegisterServerEvent("copnet:searchPerson")
AddEventHandler("copnet:searchPerson", function(query)
    local src = source
    MySQL.Async.fetchAll(
        "SELECT * FROM copnet_persons WHERE firstname LIKE @q OR lastname LIKE @q",
        {["@q"] = "%" .. query .. "%"},
        function(result)
            TriggerClientEvent("copnet:searchPersonResult", src, result)
        end
    )
end)

-- Fahrzeuge
RegisterServerEvent("copnet:searchVehicle")
AddEventHandler("copnet:searchVehicle", function(plate)
    local src = source
    MySQL.Async.fetchAll(
        "SELECT v.*, p.firstname, p.lastname FROM copnet_vehicles v LEFT JOIN copnet_persons p ON v.owner_id = p.id WHERE plate = @p",
        {["@p"] = plate},
        function(result)
            TriggerClientEvent("copnet:searchVehicleResult", src, result[1] or {})
        end
    )
end)

-- Wanted
RegisterServerEvent("copnet:setWanted")
AddEventHandler("copnet:setWanted", function(data)
    MySQL.Async.execute(
        "INSERT INTO copnet_wanted (person_id, level, notes, updated_at) VALUES (@pid, @lvl, @notes, NOW())",
        {
            ["@pid"] = data.personId,
            ["@lvl"] = data.level,
            ["@notes"] = data.notes
        }
    )
end)

RegisterServerEvent("copnet:getWanted")
AddEventHandler("copnet:getWanted", function(pid)
    local src = source
    MySQL.Async.fetchAll(
        "SELECT * FROM copnet_wanted WHERE person_id = @pid ORDER BY updated_at DESC LIMIT 1",
        {["@pid"] = pid},
        function(result)
            TriggerClientEvent("copnet:wantedData", src, result[1] or {})
        end
    )
end)

-- Leitstelle
RegisterServerEvent("copnet:createDispatch")
AddEventHandler("copnet:createDispatch", function(data)
    local src = source
    MySQL.Async.execute(
        "INSERT INTO copnet_dispatch (title, description, location, created_by, created_at) VALUES (@t, @d, @l, @c, NOW())",
        {
            ["@t"] = data.title,
            ["@d"] = data.description,
            ["@l"] = data.location,
            ["@c"] = src
        }
    )
end)

RegisterServerEvent("copnet:getDispatch")
AddEventHandler("copnet:getDispatch", function()
    local src = source
    MySQL.Async.fetchAll(
        "SELECT * FROM copnet_dispatch ORDER BY created_at DESC LIMIT 20",
        {},
        function(result)
            TriggerClientEvent("copnet:dispatchList", src, result)
        end
    )
end)
