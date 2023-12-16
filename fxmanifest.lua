--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

-- 【 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 𝗠𝗲𝘁𝗮𝗱𝗮𝘁𝗮 】--
fx_version 'cerulean'
game 'gta5'

-- 【 𝗜𝗡𝗙𝗢 】--
author 'Amirreza Jaberi'
description 'FIERAC'
version '7.0.0'

-- 【 𝗨𝗜 】--
ui_page {
    'ui/index.html'
}

files {
    'ui/*.html',
    'ui/css/*.css',
    'ui/js/*.js',

    'ui/assists/**/*.*'
}

-- 【 𝗦𝗵𝗮𝗿𝗲𝗱 】--
shared_scripts {
    'tables/*.lua',
    'configs/fire-config.lua'
}

-- 【 𝗖𝗹𝗶𝗲𝗻𝘁 】--
client_scripts {
    'src/fire-client.lua',
    'src/fire-menu.lua',
}

-- 【 𝗦𝗲𝗿𝘃𝗲𝗿 】--
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'configs/fire-webhook.lua',
    'src/fire-server.lua',
}

-- 【 𝗘𝘅𝗽𝗼𝗿𝘁 】--
exports {
    'FIREAC_CHANGE_TEMP_WHHITELIST',
    'FIREAC_CHECK_TEMP_WHITELIST',
    'FIREAC_ACTION'
}

server_exports {
    'FIREAC_CHANGE_TEMP_WHHITELIST',
    'FIREAC_CHECK_TEMP_WHITELIST',
    'FIREAC_ACTION'
}

-- 【 𝗗𝗲𝗽𝗲𝗻𝗱𝗲𝗻𝗰𝗶𝗲𝘀 】--
dependencies {
    'oxmysql',
}
