fx_version 'cerulean'
game 'gta5'

author 'cs-tricks'
description 'A FiveM bike tricks script inspired by kc tricks'
version '1.0.0'

client_scripts {
    'config.lua',
    'client/main.lua',
    'client/tricks.lua',
    'client/ui.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

ui_page 'html/index.html'