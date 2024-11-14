if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()
Framework = 'qb'

function RegisterCallback(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function GetPlayerIdent(source)
    local xPlayer = GetPlayer(source)
    return xPlayer.PlayerData.citizenid
end

function GetName(source)
    local xPlayer = GetPlayer(source)
    return xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
end

function AddItem(source, item, count)
    local xPlayer = GetPlayer(source)
    TriggerClientEvent('inventory:client:ItemBox', source,  item, 'add')
    return xPlayer.Functions.AddItem(item, count)
end

function RemoveItem(source, item, count)
    local player = GetPlayer(source)
    player.Functions.RemoveItem(item, count)
end

function AddWeapon(source, weapon, ammo)
    local xPlayer = GetPlayer(source)
    return xPlayer.Functions.AddItem(weapon, 1, nil, nil)
end

function AddMoney(source, type, amount)
    if type == 'money' then type = 'cash' end
    local xPlayer = GetPlayer(source)
    xPlayer.Functions.AddMoney(type, amount)
end

function RegisterUsableItem(item, cb)
    QBCore.Functions.CreateUseableItem(item, cb)
end

function AddVehtoDB(src, props, model, vehType)
    local xPlayer = GetPlayer(src)
    if GetResourceState('qbx_core') == 'started' then
        exports.qbx_vehicles:CreatePlayerVehicle({model=model, citizenid=xPlayer.PlayerData.citizenid})
        SendToDiscord('Vehicle Redeemed', GetPlayerName(src)..' redeemed their car!', 15158332)
    else
        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {xPlayer.PlayerData.license,xPlayer.PlayerData.citizenid,model,GetHashKey(model),'{}',props.plate,'pillboxgarage',1}, function()
            SendToDiscord('Vehicle Redeemed', GetPlayerName(src)..' redeemed their car!', 15158332)
        end)
    end
end

--taken from qb-vehicleshop
function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

function ChangePlate(source, newPlate, currPlate)
    local rest = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', {newPlate})
    if rest[1] ~= nil then
        TriggerClientEvent('nass_serverstore:notify', source, "That plate is already in use, try again")
        return false
    end

    local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {currPlate})
    if result[1] ~= nil then
        if result[1].citizenid == GetPlayerIdent(source) then
            local vehicle = json.decode(result[1].mods)
            vehicle.plate = newPlate
            MySQL.query('UPDATE player_vehicles SET plate = ?, mods = ? WHERE plate = ?', {newPlate, json.encode(vehicle), currPlate})
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

function ChangeName(source, first, last)
    local ident = GetPlayerIdent(source)
    MySQL.query('SELECT * FROM players WHERE citizenid = ?', {ident}, function (result)
        if result[1] ~= nil then
            local charInfo = json.decode(result[1].charinfo)
            charInfo.firstname = first
            charInfo.lastname = last
            MySQL.query('UPDATE players SET charinfo = ? WHERE citizenid = ?', {json.encode(charInfo), ident})
            return true
        else
            TriggerClientEvent('nass_serverstore:notify', source, "Player data was not found")
            return false
        end
    end)
end
