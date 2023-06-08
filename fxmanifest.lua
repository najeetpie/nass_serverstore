fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'Nass#1411'
description 'Nass Server Store'
version '2.0.0'

shared_scripts { 'config.lua', '@ox_lib/init.lua' }

server_scripts { 'bridge/**/server.lua', '@oxmysql/lib/MySQL.lua', 'server/*.lua' }

client_scripts { 'bridge/**/client.lua', 'client/*.lua' }


