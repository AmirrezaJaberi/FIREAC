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
version '6.2.3'

-- 【 𝗦𝗵𝗮𝗿𝗲𝗱 】--
shared_scripts {
    -- 【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗲𝗮𝘁 】--
    'tables/*.lua',
    'whitelists/*.lua',
    'configs/*.lua'
}

-- 【 𝗖𝗹𝗶𝗲𝗻𝘁 】--
client_script 'src/fire-client.lua'

-- 【 𝗦𝗲𝗿𝘃𝗲𝗿 】--
server_scripts {
    'src/fire-server.lua',
}

-- 【 𝗔𝗱𝗺𝗶𝗻 𝗠𝗲𝗻𝘂 】--
client_scripts {
    '@menuv/menuv.lua',
    'src/fire-menu.lua',
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
    'menuv',
}
