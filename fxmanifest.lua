fx_version 'cerulean'

author 'guillerp#1928 coded this resource'

game 'gta5'

client_scripts {
    'Locale.lua',
    'Locales/*.lua',
    'Client/Modules/warmenu.lua',
    'Client/Cmain.lua',
    'Client/Creation.lua',
    'Client/Modules/Functions.lua',
    'Client/Modules/Menu.lua',
    'Client/Modules/Events.lua',
    'Client/Points.lua',
    'Client/Modification.lua',
    'Client/InteractionMenu.lua'
}

server_scripts {
    'Locale.lua',
    'Locales/*.lua',
    '@mysql-async/lib/MySQL.lua',
    'Server/Classes/Player.lua',
    'Server/Smain.lua',
    'Server/Modules/Functions.lua',
    'Server/Modification.lua',
    'Server/Inventory.lua'
}

shared_scripts {
    'Shared/Config.lua'
}

ui_page 'UI/index.html'

files {
    'UI/index.html',
    'UI/script.js',
    'UI/style.css',
}

