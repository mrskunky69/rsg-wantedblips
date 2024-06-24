fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'Phil'
description 'wanted Player Blips'
version '1.0'

shared_scripts {
    'shared/config.lua', 
    '@rsg-core/shared/jobs.lua', 
    '@rsg-core/shared/gangs.lua' 
}

client_scripts {
    'client/utils.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', 
    'server/main.lua'
}
