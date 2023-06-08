Config = {}
Config.DiscordLogs = true -- Set webhook in server.lua Line 1

Config.VehicleDisplays = { --Simple vehicle spawner that allows you to display cars that are on sale in your webstore
	{
		blips = {
			enabled = true,
			pos = vector3(44.5147, -873.9191, 28.7612),
			sprite = 272,
			color = 2,
			scale = 0.85,
			shortRange = true,
			name = "Paid Vehicle Displays",
		},
		vehicles = {
			{model = "zentorno", pos = vector4(44.5147, -873.9191, 29.7612, 350.9439)}
		}
	},
}

Config.Packages = {
	["Money Package"] = { -- Exact package name from tebex
		Items = {
			{
				name = "money", -- Item or account name depending on type specified below
				amount = 2000000, -- Amount of item or money
				type = "account" -- Four types: account, item, or weapon and car
			},
		},
	},
	["Item Package"] = { -- Exact package name from tebex
		Items = {
			{
				name = "bandage", -- Item or account name depending on type specified below
				amount = 1, -- Amount of item or money
				type = "item" -- Four types: account, item, or weapon and car
			},
		},
	},
	["Weapons Package"] = { -- Exact package name from tebex
		Items = {
			{
				name = "weapon_pistol", -- Item or account name depending on type specified below
				amount = 51, -- Amount of item or money
				type = "weapon" -- Four types: account, item, or weapon and car
			},
			{
				name = "weapon_assaultrifle_mk2", -- Item or account name depending on type specified below
				amount = 551, -- Amount of item or money
				type = "weapon" -- Four types: account, item, or weapon and car
			},
		},
	},
	["Vehicles Package"] = { -- Exact package name from tebex
		Items = {
			{
				model = "zentorno", -- Item or account name depending on type specified below
				type = "car", -- Four types: account, item, or weapon and car
				vehicletype = "car", -- This is for your garage script, either car boat or air depending on what script you are using(Used for ESX)
			},
		},
	},
	["Plate Changer Package"] = { -- Exact package name from tebex
		Items = {
			{
				name = "platechanger", -- Item or account name depending on type specified below
				amount = 1, -- Amount of item or money
				type = "item" -- Four types: account, item, or weapon and car
			},
		},
	},
	["Name Changer Package"] = { -- Exact package name from tebex
		Items = {
			{
				name = "namechanger", -- Item or account name depending on type specified below
				amount = 1, -- Amount of item or money
				type = "item" -- Four types: account, item, or weapon and car
			},
		},
	},
}