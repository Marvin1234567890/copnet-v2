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
const express = require("express");
const mysql = require("mysql2/promise");
const session = require("express-session");
const bcrypt = require("bcrypt");
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(session({
    secret: "copnet-super-secret",
    resave: false,
    saveUninitialized: false
}));

const dbConfig = {
    host: "localhost",
    user: "copnet",
    password: "dein_passwort",
    database: "copnet"
};

async function getDb() {
    return await mysql.createConnection(dbConfig);
}

// Login
app.post("/api/login", async (req, res) => {
    const { username, password } = req.body;
    const db = await getDb();
    const [rows] = await db.execute("SELECT * FROM users WHERE username = ? AND active = 1", [username]);
    if (!rows.length) return res.status(400).json({ error: "User nicht gefunden" });

    const user = rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(400).json({ error: "Falsches Passwort" });

    req.session.user = { id: user.id, username: user.username, role: user.role };
    res.json({ success: true, user: req.session.user });
});

// Middleware
function requireLogin(req, res, next) {
    if (!req.session.user) return res.status(401).json({ error: "Nicht eingeloggt" });
    next();
}

function requireAdmin(req, res, next) {
    if (!req.session.user || req.session.user.role !== "admin") {
        return res.status(403).json({ error: "Keine Admin-Rechte" });
    }
    next();
}

// Personen
app.get("/api/persons/search", requireLogin, async (req, res) => {
    const q = req.query.q || "";
    const db = await getDb();
    const [rows] = await db.execute("SELECT * FROM persons WHERE name LIKE ?", [`%${q}%`]);
    res.json(rows);
});

// Fahrzeuge
app.get("/api/vehicles/search", requireLogin, async (req, res) => {
    const plate = req.query.plate || "";
    const db = await getDb();
    const [rows] = await db.execute(`
        SELECT v.*, p.name AS owner_name
        FROM vehicles v
        LEFT JOIN persons p ON v.owner_id = p.id
        WHERE v.plate LIKE ?
    `, [`%${plate}%`]);
    res.json(rows);
});

// Interne Ermittlungen
app.get("/api/cases/internal", requireLogin, async (req, res) => {
    const db = await getDb();
    const [rows] = await db.execute("SELECT * FROM cases WHERE type = 'interne_ermittlung'");
    res.json(rows);
});

// Admin: Nutzerliste
app.get("/api/admin/users", requireAdmin, async (req, res) => {
    const db = await getDb();
    const [rows] = await db.execute("SELECT id, username, role, active FROM users");
    res.json(rows);
});

// Admin: Rolle ändern
app.post("/api/admin/users/:id/role", requireAdmin, async (req, res) => {
    const id = req.params.id;
    const { role } = req.body;
    const db = await getDb();
    await db.execute("UPDATE users SET role = ? WHERE id = ?", [role, id]);
    res.json({ success: true });
});

app.listen(3000, () => console.log("COPNET API läuft auf Port 3000"));
local apiBase = "http://localhost:3000" -- oder deine Server-IP

-- PERSONEN
RegisterCommand("copnet_person", function(source, args)
    local name = table.concat(args, " ")
    if name == "" then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Bitte Namen angeben." } })
        return
    end

    local url = apiBase .. "/api/persons/search?q=" .. name

    PerformHttpRequest(url, function(statusCode, body)
        if statusCode ~= 200 then
            TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "API Fehler." } })
            return
        end

        local data = json.decode(body or "[]")
        if #data == 0 then
            TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Keine Person gefunden." } })
            return
        end

        for _, p in ipairs(data) do
            TriggerClientEvent("chat:addMessage", source, {
                args = {
                    "^2COPNET",
                    string.format("Name: %s | Geburtsdatum: %s | Adresse: %s",
                        p.name or "-",
                        p.geburtsdatum or "-",
                        p.adresse or "-")
                }
            })
        end
    end)
end)

-- FAHRZEUGE
RegisterCommand("copnet_vehicle", function(source, args)
    local plate = table.concat(args, " ")
    if plate == "" then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Bitte Kennzeichen angeben." } })
        return
    end

    local url = apiBase .. "/api/vehicles/search?plate=" .. plate

    PerformHttpRequest(url, function(statusCode, body)
        if statusCode ~= 200 then
            TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "API Fehler." } })
            return
        end

        local data = json.decode(body or "[]")
        if #data == 0 then
            TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Kein Fahrzeug gefunden." } })
            return
        end

        for _, v in ipairs(data) do
            TriggerClientEvent("chat:addMessage", source, {
                args = {
                    "^2COPNET",
                    string.format("Kennzeichen: %s | Modell: %s | Farbe: %s | Halter: %s",
                        v.plate or "-",
                        v.model or "-",
                        v.color or "-",
                        v.owner_name or "-")
                }
            })
        end
    end)
end)

-- INTERNE ERMITTLUNG
RegisterCommand("copnet_internal", function(source)
    local url = apiBase .. "/api/cases/internal"

    PerformHttpRequest(url, function(statusCode, body)
        if statusCode ~= 200 then
            TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "API Fehler." } })
            return
        end

        local data = json.decode(body or "[]")
        if #data == 0 then
            TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Keine internen Ermittlungen." } })
            return
        end

        for _, cs in ipairs(data) do
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
    end)
end)
-- PERSONENABFRAGE
RegisterCommand("copnet_person", function(source, args)
    local name = table.concat(args, " ")
    if name == "" then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Bitte Namen angeben." } })
        return
    end

    MySQL.Async.fetchAll(
        "SELECT * FROM persons WHERE name LIKE @name",
        { ["@name"] = "%" .. name .. "%" },
        function(result)
            if #result == 0 then
                TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Keine Person gefunden." } })
                return
            end

            for _, p in ipairs(result) do
                TriggerClientEvent("chat:addMessage", source, {
                    args = {
                        "^2COPNET",
                        string.format("Name: %s | Geburtsdatum: %s | Adresse: %s",
                            p.name or "-",
                            p.geburtsdatum or "-",
                            p.adresse or "-")
                    }
                })
            end
        end
    )
end, false)

-- FAHRZEUGABFRAGE
RegisterCommand("copnet_vehicle", function(source, args)
    local plate = table.concat(args, " ")
    if plate == "" then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Bitte Kennzeichen angeben." } })
        return
    end

    MySQL.Async.fetchAll(
        [[
        SELECT v.*, p.name AS owner_name
        FROM vehicles v
        LEFT JOIN persons p ON v.owner_id = p.id
        WHERE v.plate LIKE @plate
        ]],
        { ["@plate"] = "%" .. plate .. "%" },
        function(result)
            if #result == 0 then
                TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Kein Fahrzeug gefunden." } })
                return
            end

            for _, v in ipairs(result) do
                TriggerClientEvent("chat:addMessage", source, {
                    args = {
                        "^2COPNET",
                        string.format("Kennzeichen: %s | Modell: %s | Farbe: %s | Halter: %s",
                            v.plate or "-",
                            v.model or "-",
                            v.color or "-",
                            v.owner_name or "-")
                    }
                })
            end
        end
    )
end, false)
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
-- FAHNDUNG EINTRAGEN: /wanted [person_id] [level] [grund...]
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
            ["@uid"] = source -- hier kannst du später User-ID aus eigener Tabelle nehmen
        },
        function(rowsChanged)
            TriggerClientEvent("chat:addMessage", source, { args = { "^2COPNET", "Fahndungseintrag erstellt." } })
        end
    )
end, false)

-- FAHNDUNGSLISTE: /wantedlist
RegisterCommand("wantedlist", function(source, args)
    MySQL.Async.fetchAll(
        [[
        SELECT w.*, p.name AS person_name
        FROM wanted w
        JOIN persons p ON w.person_id = p.id
        ORDER BY w.created_at DESC
        ]],
        {},
        function(result)
            if #result == 0 then
                TriggerClientEvent("chat:addMessage", source, { args = { "^1COPNET", "Keine Fahndungen." } })
                return
            end

            for _, w in ipairs(result) do
                TriggerClientEvent("chat:addMessage", source, {
                    args = {
                        "^3COPNET",
                        string.format("ID: %d | Person: %s | Level: %s | Grund: %s",
                            w.id,
                            w.person_name or "-",
                            w.level or "-",
                            w.reason or "-")
                    }
                })
            end
        end
    )
end, false)
-- EINSATZ ANLEGEN: /dispatchadd [caller] [ort] [beschreibung...]
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

-- OFFENE EINSÄTZE: /dispatch
RegisterCommand("dispatch", function(source, args)
    MySQL.Async.fetchAll(
        "SELECT * FROM dispatch_calls WHERE status = 'offen' ORDER BY created_at DESC",
        {},
        function(result)
            if #result == 0 then
                TriggerClientEvent("chat:addMessage", source, { args = { "^1DISPATCH", "Keine offenen Einsätze." } })
                return
            end

            for _, call in ipairs(result) do
                TriggerClientEvent("chat:addMessage", source, {
                    args = {
                        "^3DISPATCH",
                        string.format("ID: %d | Caller: %s | Ort: %s | Beschreibung: %s",
                            call.id,
                            call.caller or "-",
                            call.location or "-",
                            call.description or "-")
                    }
                })
            end
        end
    )
end, false)
-- DIENST TOGGLEN: /dienst
RegisterCommand("dienst", function(source, args)
    MySQL.Async.fetchAll(
        "SELECT * FROM duty WHERE user_id = @uid",
        { ["@uid"] = source },
        function(result)
            local onDuty = 1
            if #result > 0 and result[1].on_duty == 1 then
                onDuty = 0
            end

            MySQL.Async.execute(
                [[
                INSERT INTO duty (user_id, on_duty)
                VALUES (@uid, @duty)
                ON DUPLICATE KEY UPDATE on_duty = @duty, last_change = NOW()
                ]],
                { ["@uid"] = source, ["@duty"] = onDuty },
                function()
                    local msg = onDuty == 1 and "Du bist jetzt im Dienst." or "Du bist jetzt außer Dienst."
                    TriggerClientEvent("chat:addMessage", source, { args = { "^2COPNET", msg } })
                end
            )
        end
    )
end, false)

-- DIENSTLISTE: /dienstlist
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
