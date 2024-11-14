if GetResourceState('qbx_core') ~= 'started' then return end
Framework = 'qbx'

function RegisterCallback(name, cb)
    lib.callback.register(name, cb)
end

function GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

---> [WIP]
function GetPlayerIdent(source)
    local Player = GetPlayer(source)
    return Player.PlayerData.citizenid
end

function GetName(source)
    local Player = GetPlayer(source)
    return Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
end

function AddItem(source, item, count)
    exports.ox_inventory:AddItem(source, item, count)
end

function RemoveItem(source, item, count)
    exports.ox_inventory:RemoveItem(source, item, count)
end

function AddWeapon(source, weapon, count)
    exports.ox_inventory:RemoveItem(source, weapon, count)
end

function AddMoney(source, type, amount)
    if type == 'money' then type = 'cash' end
    exports.ox_inventory:AddItem(source, 'money', amount)
end

function RegisterUsableItem(item, cb)
    exports.qbx_core:CreateUseableItem(item, cb)
end

function AddVehtoDB(src, model)
    local Player = GetPlayer(src)
    exports.qbx_vehicles:CreatePlayerVehicle({model = model, citizenid = Player.PlayerData.citizenid, garage = 'pillboxgarage'})
    SendToDiscord('Vehicle Redeemed', GetPlayerName(src)..' redeemed their car!', 15158332)
end

--taken from qb-vehicleshop
function GeneratePlate()
    local plate = lib.string.random('1111')
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
        TriggerClientEvent('nass_serverstore:notify', source, locale('plate.in_use'))
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
            TriggerClientEvent('nass_serverstore:notify', source, locale('must_own_veh'))
            return false
        end
    else
        TriggerClientEvent('nass_serverstore:notify', source, locale('veh_not_in_db'))
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
            TriggerClientEvent('nass_serverstore:notify', source, locale('player_not_found'))
            return false
        end
    end)
end