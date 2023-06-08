local spawnedCars = {}

RegisterNetEvent('nass_serverstore:notify', function(message)
	notify(message)
end)

function notify(message)
    if GetResourceState('nass_notifications') == 'started' then
        exports["nass_notifications"]:ShowNotification("alert", "Info", message, 5000)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(0, 1)
    end
end

RegisterNetEvent('nass_serverstore:spawnveh', function(vehType)
	ServerCallback('nass_serverstore:redeemCheck', function(isLegit, newPlate, model)
		if not isLegit or not newPlate then return end
		local carExist = false
		if newPlate == "ESXNEEDSNEWPLATE" then
			newPlate = exports['esx_vehicleshop']:GeneratePlate()
		end

		NassSpawnVehicle(model, GetEntityCoords(PlayerPedId()) - vector3(0.0, 0.0, 10.0), 0.0, function(vehicle) -- Get vehicle info
			carExist = true

			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false, false)
			FreezeEntityPosition(vehicle, true)

			local vehicleProps = GetVehicleProperties(vehicle)
			vehicleProps.plate = newPlate
			TriggerServerEvent('nass_serverstore:setVehicle', vehicleProps, model, vehType)

			SetEntityAsMissionEntity(vehicle)
			DeleteVehicle(vehicle)
		end, false)

		Wait(500)
		if carExist then return end
		TriggerServerEvent('nass_serverstore:carNotExist')
	end, model)
end)

--Taken from ESX
function NassSpawnVehicle(vehicle, coords, heading, cb, networked)
    local model = type(vehicle) == 'number' and vehicle or joaat(vehicle)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    networked = networked == nil and true or networked

    local playerCoords = GetEntityCoords(PlayerPedId())
    if not vector or not playerCoords then 
        return
    end
    local dist = #(playerCoords - vector)
    if dist > 424 then -- Onesync infinity Range (https://docs.fivem.net/docs/scripting-reference/onesync/)
        local executingResource = GetInvokingResource() or "Unknown"
        return print(("[^1ERROR^7] Resource ^5%s^7 Tried to spawn vehicle on the client but the position is too far away (Out of onesync range)."):format(executing_resource))
    end

    CreateThread(function()
		while not HasModelLoaded(model) do Wait(0) RequestModel(model) end

        local vehicle = CreateVehicle(model, vector.x, vector.y, vector.z, heading, networked, true)

        if networked then
            local id = NetworkGetNetworkIdFromEntity(vehicle)
            SetNetworkIdCanMigrate(id, true)
            SetEntityAsMissionEntity(vehicle, true, true)
        end
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetModelAsNoLongerNeeded(model)
        SetVehRadioStation(vehicle, 'OFF')

        RequestCollisionAtCoord(vector.xyz)
        while not HasCollisionLoadedAroundEntity(vehicle) do
            Wait(0)
        end

        if cb then
            cb(vehicle)
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	
	for k, v in pairs(spawnedCars) do
        SetEntityAsMissionEntity(v)
		DeleteVehicle(v)
	end
end)


Citizen.CreateThread(function()
    for k,v in pairs(Config.VehicleDisplays) do
        local blip = AddBlipForCoord(v.blips.pos.x, v.blips.pos.y, v.blips.pos.z)
        SetBlipSprite(blip, v.blips.sprite)
        SetBlipScale(blip, v.blips.scale)
        SetBlipColour(blip, v.blips.color)
        SetBlipAsShortRange(blip, v.blips.shortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.blips.name)
        EndTextCommandSetBlipName(blip)

        for r, n in pairs(v.vehicles) do
            CreateDisplayVehicle(n.pos, n.model, "PAIDCAR")	
        end
    end
	
	Wait(1000)
end)

function CreateDisplayVehicle(pos, model, plate)
	local hashkey = GetHashKey(model)
	RequestModel(hashkey) 
    while not HasModelLoaded(hashkey) do Wait(1) end

	local vehicle = CreateVehicle(hashkey, pos.x, pos.y, pos.z, false, false)
	SetVehicleOnGroundProperly(vehicle)
	FreezeEntityPosition(vehicle, true)
	SetEntityHeading(vehicle, pos.w)
	SetEntityInvincible(vehicle, true)
	SetVehicleDoorsLocked(vehicle, 2)
	SetVehicleNumberPlateText(vehicle, plate)
    table.insert(spawnedCars, vehicle)
	Citizen.Wait(100)
	SetModelAsNoLongerNeeded(hashkey)
end

RegisterNetEvent('nass_serverstore:openPlateChange')
AddEventHandler('nass_serverstore:openPlateChange', function()
	ServerCallback('nass_serverstore:hasAccess', function(canUse)
		if canUse then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			if vehicle ~= 0 then
				local currPlate = GetVehicleNumberPlateText(vehicle)
				local input = lib.inputDialog('Plate Change', {'What would you like your new plate to be?'})
                if not input then return end

                local newPlate = tostring(input[1])
                local newPlateLength = #newPlate
				if newPlate then
                    newPlate = string.upper(newPlate)
                    if newPlateLength <= 0 then
                        notify('Plate is too short')
                    elseif 8 < newPlateLength then
                        notify('Plate is too long')
                    else
						ServerCallback('nass_serverstore:changeplate', function(shouldChange)
                            print(shouldChange)
							if shouldChange then
								SetVehicleNumberPlateText(vehicle, newPlate)
                                notify('Plate has been changed from ' .. currPlate .. ' to ' .. newPlate)
							end
						end, newPlate, currPlate)
                    end
				end
			else
				notify('You must be in a vehicle')
			end
		end
	end, "plate")
end)

RegisterNetEvent('nass_serverstore:openNameChange')
AddEventHandler('nass_serverstore:openNameChange', function()
	ServerCallback('nass_serverstore:hasAccess', function(canUse)
		if canUse then
			local input = lib.inputDialog('Name Change', {'First Name?', 'Last Name?'})
			if not input then return end
			local first = tostring(input[1])
			local last = tostring(input[2])

			ServerCallback('nass_serverstore:changename', function(shouldChange)
				if shouldChange then
					notify("You have changed your name to "..first.." "..last..".")
				end
			end, first, last)
		end
	end, "name")
end)