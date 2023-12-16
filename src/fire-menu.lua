--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

local isAdmin = false


RegisterCommand('fireacmenu', function()
    if isAdmin then

    end
end, false)

RegisterKeyMapping("fireacmenu", "FIREAC admin menu", "keyboard", FIREAC.AdminMenu.Key)
