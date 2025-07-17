fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.1'
author 'TGIANN | https://tgiann.com'
description 'TGIANN Ped Scale - Height and Weight'

dependencies {
	'ox_lib',
}

shared_scripts {
	'@ox_lib/init.lua',
	'configs/*.lua',
	'languages/*.lua',
	'shared/*.lua',
}

client_scripts {
	'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}
