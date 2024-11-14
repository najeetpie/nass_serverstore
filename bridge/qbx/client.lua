if GetResourceState('qbx_core') ~= 'started' then return end

function GetVehicleProperties(vehicle)
    return lib.getVehicleProperties(vehicle)
end

function ServerCallback(name, cb, ...)
    lib.callback(name, cb,  ...)
end