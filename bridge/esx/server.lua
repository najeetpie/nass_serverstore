if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()
Framework = 'esx'


function RegisterCallback(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function GetPlayerIdent(source)
    local xPlayer = GetPlayer(source)
    return xPlayer.identifier
end

function getName(source)
    local xPlayer = GetPlayer(source)
    return xPlayer.getName()
end

function addItem(source, itemName, count)
    local xPlayer = GetPlayer(source)
    return xPlayer.addInventoryItem(itemName, count)
end

function RemoveItem(source, item, count)
    local player = GetPlayer(source)
    player.removeInventoryItem(item, count)
end


function addWeapon(source, weaponName, ammo)
    local xPlayer = GetPlayer(source)
    xPlayer.addWeapon(weaponName, ammo)
end

function addMoney(source, type, amount)
    if type == 'cash' then type = 'money' end
    local player = GetPlayer(source)
    player.addAccountMoney(type, amount)
end

function RegisterUsableItem(item, cb)
    ESX.RegisterUsableItem(item, cb)
end

function addVehtoDB(src, props, model, vehType)
    local xPlayer = GetPlayer(src)
    MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (?, ?, ?, ?)', {xPlayer.identifier,props.plate,json.encode(props),vehType}, function()
        SendToDiscord('Vehicle Redeemed', GetPlayerName(src)..' redeemed their car!', 15158332)
    end)
end

function GeneratePlate()
    return "ESXNEEDSNEWPLATE"
end


function changePlate(source, newPlate, currPlate)
    local rest = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {newPlate})
    if rest[1] ~= nil then
        TriggerClientEvent('nass_serverstore:notify', source, "That plate is already in use, try again")
        return false
    end
  
    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {currPlate})
    if result[1] ~= nil then
        if result[1].owner == GetPlayerIdent(source) then
            local vehicle = json.decode(result[1].vehicle)
            vehicle.plate = tostring(newPlate)
            MySQL.query('UPDATE owned_vehicles SET plate = ?, vehicle = ? WHERE plate = ?', {newPlate, json.encode(vehicle), currPlate})
            return true     
        else
            TriggerClientEvent('nass_serverstore:notify', source, "You must own the vehicle")
            return false
        end
    else
        TriggerClientEvent('nass_serverstore:notify', source, "This vehicle is not in the database")
        return false
    end
end

function changeName(source, first, last)
    MySQL.query('UPDATE users SET firstname = ?, lastname = ? WHERE identifier = ?', {first, last, GetPlayerIdent(source)})
    return true
end