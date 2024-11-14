fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'Nass#1411'
description 'Nass Server Store'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    'server/*.lua',
    'bridge/**/server.lua',
    '@oxmysql/lib/MySQL.lua',
}

client_scripts {
    'client/*.lua',
    'bridge/**/client.lua',
    -- '@qbx_core/modules/playerdata.lua' -- Uncomment if using QBX
}

ox_lib 'locale'
files {
    'locales/*.json'
}
