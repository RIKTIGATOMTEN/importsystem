fx_version 'cerulean'
game 'gta5'
lua54 "yes"
author "none"


client_scripts {'src/client/*.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua', 'src/server/*.lua'}
shared_scripts {'configuration/*.lua'}
escrow_ignore "configuration/config.lua"
dependency '/assetpacks'
dependency 'oxmysql'
