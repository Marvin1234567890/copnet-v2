local open = false

RegisterCommand("copnet", function()
    open = not open
    SetNuiFocus(open, open)
    SendNUIMessage({ action = "toggle", state = open })
end)

RegisterNUICallback("close", function(data, cb)
    open = false
    SetNuiFocus(false, false)
    cb({})
end)
-- COPNET V2 – client.lua

local open = false

-- NUI öffnen/schließen
RegisterCommand("copnet", function()
    open = not open
    SetNuiFocus(open, open)
    SendNUIMessage({ action = "toggle", state = open })
end)

-- NUI schließen
RegisterNUICallback("close", function(_, cb)
    open = false
    SetNuiFocus(false, false)
    cb({})
end)

--------------------------------
-- PERSONEN
--------------------------------
RegisterNUICallback("searchPerson", function(data, cb)
    TriggerServerEvent("copnet:searchPerson", data.query)
    cb({})
end)

RegisterNetEvent("copnet:returnPerson")
AddEventHandler("copnet:returnPerson", function(result)
    SendNUIMessage({
        action = "returnPerson",
        data = result
    })
end)

--------------------------------
-- FAHRZEUGE
--------------------------------
RegisterNUICallback("searchVehicle", function(data, cb)
    TriggerServerEvent("copnet:searchVehicle", data.plate)
    cb({})
end)

RegisterNetEvent("copnet:returnVehicle")
AddEventHandler("copnet:returnVehicle", function(result)
    SendNUIMessage({
        action = "returnVehicle",
        data = result
    })
end)

--------------------------------
-- WANTED
--------------------------------
RegisterNUICallback("getWanted", function(_, cb)
    TriggerServerEvent("copnet:getWanted")
    cb({})
end)

RegisterNetEvent("copnet:returnWanted")
AddEventHandler("copnet:returnWanted", function(result)
    SendNUIMessage({
        action = "returnWanted",
        data = result
    })
end)

--------------------------------
-- DISPATCH
--------------------------------
RegisterNUICallback("getDispatch", function(_, cb)
    TriggerServerEvent("copnet:getDispatch")
    cb({})
end)

RegisterNetEvent("copnet:returnDispatch")
AddEventHandler("copnet:returnDispatch", function(result)
    SendNUIMessage({
        action = "returnDispatch",
        data = result
    })
end)

--------------------------------
-- DIENST
--------------------------------
RegisterNUICallback("toggleDuty", function(_, cb)
    TriggerServerEvent("copnet:toggleDuty")
    cb({})
end)

RegisterNetEvent("copnet:returnDuty")
AddEventHandler("copnet:returnDuty", function(duty)
    SendNUIMessage({
        action = "returnDuty",
        data = duty
    })
end)

--------------------------------
-- INTERNE ERMITTLUNGEN
--------------------------------
RegisterNUICallback("getInternal", function(_, cb)
    TriggerServerEvent("copnet:getInternal")
    cb({})
end)

RegisterNetEvent("copnet:returnInternal")
AddEventHandler("copnet:returnInternal", function(result)
    SendNUIMessage({
        action = "returnInternal",
        data = result
    })
end)
--------------------------------
-- WANTED – NUI
--------------------------------
RegisterNUICallback("addWanted", function(data, cb)
    TriggerServerEvent("copnet:addWanted", data)
    cb({})
end)

--------------------------------
-- DISPATCH – Einsatz übernehmen
--------------------------------
RegisterNUICallback("takeDispatch", function(data, cb)
    TriggerServerEvent("copnet:takeDispatch", data)
    cb({})
end)

--------------------------------
-- DIENSTLISTE
--------------------------------
RegisterNUICallback("getDutyList", function(_, cb)
    TriggerServerEvent("copnet:getDutyList")
    cb({})
end)

RegisterNetEvent("copnet:returnDutyList")
AddEventHandler("copnet:returnDutyList", function(result)
    SendNUIMessage({
        action = "returnDutyList",
        data = result
    })
end)

--------------------------------
-- ADMIN – Userliste
--------------------------------
RegisterNUICallback("getAdminUsers", function(_, cb)
    TriggerServerEvent("copnet:getAdminUsers")
    cb({})
end)

RegisterNetEvent("copnet:returnAdminUsers")
AddEventHandler("copnet:returnAdminUsers", function(result)
    SendNUIMessage({
        action = "returnAdminUsers",
        data = result
    })
end)
