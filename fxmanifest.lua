fx_version 'cerulean'
game 'gta5'
author 'arduinodenis.it'
description 'ArDenHub Fishing Script with ESX and ox_lib'
version '2.0.0'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'oxmysql',
}