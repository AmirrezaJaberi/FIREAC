-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2026 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0

fx_version 'cerulean'
game 'gta5'

author 'Amirreza Jaberi'
description 'FIREAC hardened anti-cheat and admin UI'
version '7.2.18'

ui_page 'ui/index.html'

files {
    'ui/*.html',
    'ui/css/*.css',
    'ui/js/*.js',
    'ui/assists/**/*.*'
}

shared_scripts {
    'tables/*.lua',
    'configs/fire-config.lua'
}

client_scripts {
    'src/fire-client.lua',
    'src/fire-menu.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'configs/fire-webhook.lua',
    'src/fire-server.lua'
}

exports {
    'FIREAC_CHANGE_TEMP_WHITELIST',
    'FIREAC_CHANGE_TEMP_WHHITELIST',
    'FIREAC_CHECK_TEMP_WHITELIST',
    'FIREAC_ACTION'
}

server_exports {
    'FIREAC_CHANGE_TEMP_WHITELIST',
    'FIREAC_CHANGE_TEMP_WHHITELIST',
    'FIREAC_CHECK_TEMP_WHITELIST',
    'FIREAC_ACTION',
    'FIREAC_BAN_PLAYER',
    'BanPlayer',
    'FIREAC_UNBAN_PLAYER',
    'UnbanPlayer'
}

dependencies {
    'oxmysql'
}
