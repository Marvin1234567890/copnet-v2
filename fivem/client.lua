local open = false

RegisterCommand("copnet", function()
    open = not open
    SetNuiFocus(open, open)
    SendNUIMessage({ action = "toggle", state = open })
end)

RegisterNUICallback("close", function(_, cb)
    open = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("searchPerson", function(data, cb)
    TriggerServerEvent("copnet:searchPerson", data.query)
    cb("ok")
end)

RegisterNUICallback("searchVehicle", function(data, cb)
    TriggerServerEvent("copnet:searchVehicle", data.plate)
    cb("ok")
end)

RegisterNUICallback("setWanted", function(data, cb)
    TriggerServerEvent("copnet:setWanted", data)
    cb("ok")
end)

RegisterNUICallback("getWanted", function(data, cb)
    TriggerServerEvent("copnet:getWanted", data.personId)
    cb("ok")
end)

RegisterNUICallback("createDispatch", function(data, cb)
    TriggerServerEvent("copnet:createDispatch", data)
    cb("ok")
end)

RegisterNUICallback("getDispatch", function(_, cb)
    TriggerServerEvent("copnet:getDispatch")
    cb("ok")
end)

RegisterNetEvent("copnet:searchPersonResult")
AddEventHandler("copnet:searchPersonResult", function(result)
    SendNUIMessage({ action = "searchPersonResult", data = result })
end)

RegisterNetEvent("copnet:searchVehicleResult")
AddEventHandler("copnet:searchVehicleResult", function(result)
    SendNUIMessage({ action = "searchVehicleResult", data = result })
end)

RegisterNetEvent("copnet:wantedData")
AddEventHandler("copnet:wantedData", function(data)
    SendNUIMessage({ action = "wantedData", data = data })
end)

RegisterNetEvent("copnet:dispatchList")
AddEventHandler("copnet:dispatchList", function(list)
    SendNUIMessage({ action = "dispatchList", data = list })
end)
