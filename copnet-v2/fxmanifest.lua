fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

client_script 'client.lua'
server_script '@mysql-async/lib/MySQL.lua'
server_script 'server.lua'
