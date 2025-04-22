fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'arduinodenis.it'
description 'ArdenHub Fishing Script with ESX and ox_lib -- discord.gg/s9bjshtmjG'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}