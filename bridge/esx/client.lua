if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()


function GetVehicleProperties(vehicle)
    return ESX.Game.GetVehicleProperties(vehicle)
end

function ServerCallback(name, cb, ...)
    ESX.TriggerServerCallback(name, cb,  ...)
end

