local DiscordWebhook = 'CHANGE_WEBHOOK'
local inProgress = false
local plateTable, nameTable, Charset, redeemedCars = {}, {}, {}, {}

RegisterCallback('nass_serverstore:redeemCheck', function(source, cb, model)
	local identifier = GetPlayerIdent(source)
	if redeemedCars[identifier] ~= nil then
		cb(true, GeneratePlate(), redeemedCars[identifier])
	else
		print('[nass_serverstore]: A player tried to exploit the vehicle spawn trigger! Identifier: '..identifier)
		SendToDiscord('Attempted Exploit Detected!', '**Identifier: **'..identifier..'\n**Comments:** Player has attempted to trigger the spawn vehicle event without a redemption code.', 3066993)
		DropPlayer(source, "Attempted exploit was detected")
		cb(false)
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		local tebexConvar = GetConvar('sv_tebexSecret', '')
		if tebexConvar == '' then
			error('Tebex Secret Missing please set in server.cfg and try again. The script will not work without it.')
			StopResource(GetCurrentResourceName())
		end
		if not Config.DiscordLogs then
			print('^3Webhooks Disabled^0') -- ^3 is the yellow color code for the console, ^0 is white to reset the color for everything after this message
		end
	end
end)

RegisterCommand('redeem', function(source, _, rawCommand)
	local tbxid = rawCommand:sub(8)
	local identifier = GetPlayerIdent(source)
	local xName = getName(source)
	MySQL.query('SELECT * FROM codes WHERE code = @playerCode', {['@playerCode'] = tbxid}, function(result)
		if result[1] then
			local boughtPackages = json.decode(result[1].packagename)
			for _, i in pairs(boughtPackages) do
				local packageFound = false
				if Config.Packages[i] ~= nil then
					for h, j in pairs(Config.Packages[i].Items) do
						if j.type == 'item' then
							addItem(source, j.name, j.amount)
						elseif j.type == 'weapon' then
							addWeapon(source, j.name, j.amount)
						elseif j.type == 'account' then
							addMoney(source, j.name, j.amount)
						elseif j.type == 'car' then
							redeemedCars[identifier] = j.model
							TriggerClientEvent('nass_serverstore:spawnveh', source, j.vehicletype)
							Wait(500)	
						end
						Wait(100)
					end
					TriggerClientEvent('nass_serverstore:notify', source, "You have successfully redeemed a code for: " .. tbxid)
					SendToDiscord('Code Redeemed', '**Package Name: **'..i..'\n**Character Name: **'..xName..'\n**Identifier: **'..identifier, 3066993)
				else
					TriggerClientEvent('nass_serverstore:notify', source, "The "..i.." package is not configured by the server owner. Please contact the admin team.")
				end	
			end
			MySQL.query.await('DELETE FROM codes WHERE code = @playerCode', {['@playerCode'] = tbxid})
		else
			TriggerClientEvent('nass_serverstore:notify', source, "Code is currently invalid, if you have just purchased please try this code again in a few minutes")
		end
	end)
end, false)

RegisterCommand('purchase_package_tebex', function(source, args)
	if source == 0 then
		local dec = json.decode(args[1])
		local tbxid = dec.transid
		local packTab = {}
		while inProgress do
			Wait(1000)
		end
		inProgress = true
		MySQL.query('SELECT * FROM codes WHERE code = @playerCode', {['@playerCode'] = tbxid}, function(result)
			if result[1] then
				local packagetable = json.decode(result[1].packagename)
				packagetable[#packagetable+1] = dec.packagename
				MySQL.update('UPDATE codes SET packagename = ? WHERE code = ?', {json.encode(packagetable), tbxid}, function(rowsChanged)
					if rowsChanged > 0 then
						SendToDiscord('Purchase', '`'..dec.packagename..'` was just purchased and inserted into the database under redeem code: `'..tbxid..'`.', 1752220)
					else
						SendToDiscord('Error', '`'..tbxid..'` was not inserted into database. Please check for errors!', 15158332)
					end
				end)
			else
				packTab[#packTab+1] = dec.packagename
				MySQL.insert("INSERT INTO codes (code, packagename) VALUES (?, ?)", {tbxid, json.encode(packTab)}, function(rowsChanged)
					SendToDiscord('Purchase', '`'..dec.packagename..'` was just purchased and inserted into the database under redeem code: `'..tbxid..'`.', 1752220)
					print('^2Purchase '..tbxid..' was succesfully inserted into the database.^0')
				end)
			end
			inProgress = false
		end)
	else
		print(GetPlayerName(source)..' tried to give themself a store code.')
		SendToDiscord('Attempted Exploit', GetPlayerName(source)..' tried to give themself a store code!', 15158332)
	end
end, false)

RegisterNetEvent('nass_serverstore:setVehicle', function (vehicleProps, model, vehType)
	local src = source
	local identifier = GetPlayerIdent(src)
	if redeemedCars[identifier] == model then
		addVehtoDB(src, vehicleProps, model, vehType)
	else
		print('[nass_serverstore]: A player tried to exploit the vehicle spawn trigger! Identifier: '..identifier)
		SendToDiscord('Attempted Exploit Detected!', '**Identifier: **'..identifier..'\n**Comments:** Player has attempted to trigger the spawn vehicle event without a redemption code.', 3066993)
		DropPlayer(src, "Attempted exploit was detected")
	end
end)

RegisterNetEvent('nass_serverstore:carNotExist', function()
	SendToDiscord('Vehicle Error', GetPlayerName(source)..' couldn\'t redeem their car!', 15158332)
end)

RegisterUsableItem('platechanger',function(source,remove,item) 
	local identifier = GetPlayerIdent(source)
	plateTable[identifier] = true
	TriggerClientEvent("nass_serverstore:openPlateChange", source)
end)

RegisterUsableItem('namechanger',function(source,remove,item) 
	local identifier = GetPlayerIdent(source)
	nameTable[identifier] = true
	TriggerClientEvent("nass_serverstore:openNameChange", source)
end)

RegisterCallback("nass_serverstore:hasAccess", function(source, cb, accType)
	local identifier = GetPlayerIdent(source)
	if accType == "plate" then
		cb(plateTable[identifier])
	elseif accType == "name" then
		cb(nameTable[identifier])
	else
		SendToDiscord(accType, GetPlayerName(source)..' has been caught cheating .', 1752220)
		DropPlayer(source, "Attempted exploit was detected")
		cb(false)
	end
end)

RegisterCallback("nass_serverstore:changename", function(source, cb, first, last)
	local src = source
	local identifier = GetPlayerIdent(src)
    if changeName(src, first, last) then
		RemoveItem(src, 'namechanger', 1)
		SendToDiscord('Name Change', GetPlayerName(src)..' has changed their name to '..first..' '.. last.. '.', 1752220)
		cb(true)
	else
		cb(false)
	end
	nameTable[identifier] = nil
end)

RegisterCallback("nass_serverstore:changeplate", function(source, cb, newPlate, currPlate)
	local src = source
	local identifier = GetPlayerIdent(src)
    if changePlate(src, newPlate, currPlate) then
		RemoveItem(src, 'platechanger', 1)
		SendToDiscord('Plate Change', GetPlayerName(src)..' has changed their plate to '..newPlate..'.', 1752220)
		cb(true)
	else
		cb(false)
	end
	plateTable[identifier] = nil
end)



local DISCORD_NAME = "nass_serverstore"
local DISCORD_IMAGE = "https://i.imgur.com/Q72RWcB.png"

function SendToDiscord(name, message, color)
	if not Config.DiscordLogs then return end
	if DiscordWebhook == "CHANGE_WEBHOOK" then
		print(message)
	else
		local connect = {
			{
				["color"] = color,
				["title"] = "**".. name .."**",
				["description"] = message,
				["footer"] = {
					["text"] = "Nass Tebexstore",
				},
			}
		}
		PerformHttpRequest(DiscordWebhook, function() end, 'POST', json.encode({username = DISCORD_NAME, embeds = connect, avatarrl = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
	end
end
