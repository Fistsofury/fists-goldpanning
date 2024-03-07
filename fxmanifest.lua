game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'Fistsofury'
description 'Fists Gold Panning'

server_scripts {
    '/server/*.lua'
}

shared_scripts {
    'config.lua',
    'locale.lua',
    'languages/*.lua'
}


client_scripts {
    '/client/*.lua'

}

dependencies {
    'vorp_inventory',
    'bcc-utils'
}
