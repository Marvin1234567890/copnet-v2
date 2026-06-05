-- COPNET V2 – server.lua
-- Nutzt mysql-async (@mysql-async/lib/MySQL.lua muss im fxmanifest stehen)
-- Features:
--  - Personenabfrage
--  - Fahrzeugabfrage
--  - Wanted-System
--  - Dispatch / Leitstelle
--  - Dienstsystem
--  - Interne Ermittlungen
--  - NUI-Rückgaben

--------------------------------
-- PERSONEN
--------------------------------
RegisterNetEvent("copnet:searchPerson")
AddEventHandler("copnet:searchPerson", function(query)
    local src = source

    MySQL.Async.fetchAll(
        "SELECT * FROM persons WHERE name LIKE @q",
        { ["@q"] = "%" .. query .. "%" },
        function(result)
            TriggerClientEvent("copnet:returnPerson", src, result)
        end
    )
end)

--------------------------------
-- FAHRZEUGE
--------------------------------
RegisterNetEvent("copnet:searchVehicle")
AddEventHandler("copnet:searchVehicle", function(plate)
    local src = source

    MySQL.Async.fetchAll(
        [[
        SELECT v.*, p.name AS owner_name
        FROM vehicles v
        LEFT JOIN persons p ON v.owner_id = p.id
        WHERE v.plate LIKE @p
        ]],
        { ["@p"] = "%" .. plate .. "%" },
        function(result)
            TriggerClientEvent("copnet:returnVehicle", src, result)
        end
    )
end)

--------------------------------
-- WANTED – Liste
--------------------------------
RegisterNetEvent("copnet:getWanted")
AddEventHandler("copnet:getWanted", function()
    local src = source

    MySQL.Async.fetchAll(
        [[
        SELECT w.*, p.name AS person_name
        FROM wanted w
        JOIN persons p ON w.person_id = p.id
        ORDER BY w.created_at DESC
        ]],
        {},
        function(result)
            TriggerClientEvent("copnet:returnWanted", src, result)
        end
    )
end)

-- Optional: Wanted hinzufügen per Command
RegisterCommand("wanted", function(source, args)
    local person_id = tonumber(args[1])
    local level = args[2]
    local reason = table.concat(args, " ", 3)

    if not person_id or not level or reason == "" then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Nutze: /wanted [person_id] [niedrig/mittel/hoch/sehr_hoch] [Grund]" } })
        return
    end

    MySQL.Async.execute(
        "INSERT INTO wanted (person_id, reason, level, created_by) VALUES (@pid, @reason, @level, @uid)",
        {
            ["@pid"] = person_id,
            ["@reason"] = reason,
            ["@level"] = level,
            ["@uid"] = source
        },
        function()
            TriggerClientEvent("chat:addMessage", source, { args = { "^2COPNET", "Fahndungseintrag erstellt." } })
        end
    )
end, false)

--------------------------------
-- DISPATCH / LEITSTELLE
--------------------------------
RegisterNetEvent("copnet:getDispatch")
AddEventHandler("copnet:getDispatch", function()
    local src = source

    MySQL.Async.fetchAll(
        "SELECT * FROM dispatch_calls WHERE status = 'offen' ORDER BY created_at DESC",
        {},
        function(result)
            TriggerClientEvent("copnet:returnDispatch", src, result)
        end
    )
end)

-- Optional: Einsatz anlegen per Command
RegisterCommand("dispatchadd", function(source, args)
    local caller = args[1]
    local location = args[2]
    local description = table.concat(args, " ", 3)

    if not caller or not location or description == "" then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1DISPATCH", "Nutze: /dispatchadd [Caller] [Ort] [Beschreibung]" } })
        return
    end

    MySQL.Async.execute(
        "INSERT INTO dispatch_calls (caller, location, description) VALUES (@c, @l, @d)",
        {
            ["@c"] = caller,
            ["@l"] = location,
            ["@d"] = description
        },
        function()
            TriggerClientEvent("chat:addMessage", source, { args = { "^2DISPATCH", "Einsatz angelegt." } })
        end
    )
end, false)

--------------------------------
-- DIENSTSYSTEM
--------------------------------
RegisterNetEvent("copnet:toggleDuty")
AddEventHandler("copnet:toggleDuty", function()
    local src = source

    MySQL.Async.fetchAll(
        "SELECT * FROM duty WHERE user_id = @u",
        { ["@u"] = src },
        function(result)
            local duty = 1
            if #result > 0 and result[1].on_duty == 1 then
                duty = 0
            end

            MySQL.Async.execute(
                [[
                INSERT INTO duty (user_id, on_duty)
                VALUES (@u, @d)
                ON DUPLICATE KEY UPDATE on_duty = @d, last_change = NOW()
                ]],
                { ["@u"] = src, ["@d"] = duty }
            )

            TriggerClientEvent("copnet:returnDuty", src, duty)
        end
    )
end)

-- Optional: Dienstliste per Command
RegisterCommand("dienstlist", function(source, args)
    MySQL.Async.fetchAll(
        [[
        SELECT d.user_id, d.on_duty, d.last_change
        FROM duty d
        ORDER BY d.last_change DESC
        ]],
        {},
        function(result)
            if #result == 0 then
                TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Keine Dienstdaten." } })
                return
            end

            for _, d in ipairs(result) do
                local status = d.on_duty == 1 and "im Dienst" or "außer Dienst"
                TriggerClientEvent("chat:addMessage", source, {
                    args = {
                        "^3COPNET",
                        string.format("ID: %d | Status: %s | Letzte Änderung: %s",
                            d.user_id,
                            status,
                            d.last_change or "-")
                    }
                })
            end
        end
    )
end, false)

--------------------------------
-- INTERNE ERMITTLUNGEN
--------------------------------
RegisterNetEvent("copnet:getInternal")
AddEventHandler("copnet:getInternal", function()
    local src = source

    MySQL.Async.fetchAll(
        "SELECT * FROM cases WHERE type = 'interne_ermittlung' ORDER BY created_at DESC",
        {},
        function(result)
            TriggerClientEvent("copnet:returnInternal", src, result)
        end
    )
end)

-- Optional: Chat-Command für Übersicht
RegisterCommand("copnet_internal", function(source, args)
    MySQL.Async.fetchAll(
        "SELECT * FROM cases WHERE type = 'interne_ermittlung' ORDER BY created_at DESC",
        {},
        function(result)
            if #result == 0 then
                TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Keine internen Ermittlungen." } })
                return
            end

            for _, cs in ipairs(result) do
                TriggerClientEvent("chat:addMessage", source, {
                    args = {
                        "^3COPNET",
                        string.format("Fall #%d: %s | Status: %s | Erstellt: %s",
                            cs.id,
                            cs.title,
                            cs.status,
                            cs.created_at)
                    }
                })
            end
        end
    )
end, false)
--------------------------------
-- WANTED – Eintrag per NUI
--------------------------------
RegisterNetEvent("copnet:addWanted")
AddEventHandler("copnet:addWanted", function(data)
    local src = source
    local person_id = tonumber(data.person_id)
    local level = data.level
    local reason = data.reason or ""

    if not person_id or not level or reason == "" then
        TriggerClientEvent("copnet:notify", src, "Ungültige Wanted-Daten.")
        return
    end

    MySQL.Async.execute(
        "INSERT INTO wanted (person_id, reason, level, created_by) VALUES (@pid, @reason, @level, @uid)",
        {
            ["@pid"] = person_id,
            ["@reason"] = reason,
            ["@level"] = level,
            ["@uid"] = src
        },
        function()
            TriggerClientEvent("copnet:notify", src, "Wanted-Eintrag erstellt.")
        end
    )
end)

--------------------------------
-- DISPATCH – Einsatz übernehmen
--------------------------------
RegisterNetEvent("copnet:takeDispatch")
AddEventHandler("copnet:takeDispatch", function(data)
    local src = source
    local call_id = tonumber(data.id)

    if not call_id then
        TriggerClientEvent("copnet:notify", src, "Ungültige Einsatz-ID.")
        return
    end

    MySQL.Async.execute(
        "UPDATE dispatch_calls SET status = 'in_bearbeitung', taken_by = @uid WHERE id = @id",
        {
            ["@uid"] = src,
            ["@id"] = call_id
        },
        function()
            TriggerClientEvent("copnet:notify", src, "Einsatz übernommen.")
        end
    )
end)

--------------------------------
-- DIENSTLISTE – für NUI
--------------------------------
RegisterNetEvent("copnet:getDutyList")
AddEventHandler("copnet:getDutyList", function()
    local src = source

    MySQL.Async.fetchAll(
        [[
        SELECT d.user_id, d.on_duty, d.last_change
        FROM duty d
        ORDER BY d.last_change DESC
        ]],
        {},
        function(result)
            TriggerClientEvent("copnet:returnDutyList", src, result)
        end
    )
end)

--------------------------------
-- ADMIN – einfache Userliste (Beispiel)
--------------------------------
RegisterNetEvent("copnet:getAdminUsers")
AddEventHandler("copnet:getAdminUsers", function()
    local src = source

    MySQL.Async.fetchAll(
        "SELECT id, name, rank FROM persons ORDER BY id ASC LIMIT 50",
        {},
        function(result)
            TriggerClientEvent("copnet:returnAdminUsers", src, result)
        end
    )
end)

-- einfache Notify
RegisterNetEvent("copnet:notify")
AddEventHandler("copnet:notify", function(msg)
    local src = source
    TriggerClientEvent("chat:addMessage", src, { args = { "^2COPNET", msg } })
end)
