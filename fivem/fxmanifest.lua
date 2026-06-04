fx_version 'cerulean'
game 'gta5'

name 'copnet_v2'
author 'Marvin'
description 'COPNET V2 Enterprise'
version '1.0.0'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}
