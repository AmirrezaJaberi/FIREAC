<h1 align='center'><img src="https://github.com/AmirrezaJaberi/AmirrezaJaberi/blob/main/assist/logo/fireac.png" alt="FIREAC logo" height="20" width="20"> FIREAC <img src="https://github.com/AmirrezaJaberi/AmirrezaJaberi/blob/main/assist/logo/fireac.png" alt="FIREAC logo" height="20" width="20"></h1>
<p align='center'><b><a href='https://discord.gg/uvccDWtqhv'>Discord</a> - <a href='https://amirrezajaberi.ir/fireac'>Website</a></b></p>

---

[FIREAC](https://github.com/AmirrezaJaberi/FIREAC/) is the best free FiveM anti-cheat created by Amirreza Jaberi for you, FiveM server owners, and developers. This anti-cheat is designed to help you eliminate cheaters and ensure a fair gaming experience for your players.

---

### Advertisement

<p align='center'>
  For an enhanced <b>paid anticheat</b>, visit <a href="https://store.fiveguard.ac">https://store.fiveguard.ac</a>.
</p>
<p align='center'>
  We are able to provide this <strong>free product</strong> thanks to the support of <a href="https://fiveguard.net">https://fiveguard.net</a>.
</p>
<p align='center'>
  <strong>Fiveguard</strong> - Elevating your FiveM server security.
</p>

---

### Requirements

<table align='center'>
  <tr>
    <td align='center'>
      <a href="https://github.com/jaimeadf/discord-screenshot/releases">discord-screenshot</a><br>For taking screenshots
    </td>
    <td align='center'>
      <a href="https://github.com/overextended/oxmysql/releases">oxmysql</a><br>For saving SQL data
    </td>
  </tr>
</table>

---

### Features

**Client Side Protection**

- Anti-Track Players
- Anti-Health Hack
- Anti-Armor Hack
- Anti-Infinite Ammo
- Anti-Spectate
- Anti-Ragdoll
- Anti-Menyoo
- Anti-Aim Assist
- Anti-Infinite Stamina
- Anti-Aim Bot
- Anti-Blacklist Weapon
- Anti-Add Weapon
- Anti-Remove Weapon
- Anti-God Mode
- Anti-Noclip
- Anti-Rainbow Vehicle
- Anti-Teleport Vehicle
- Anti-Teleport Ped
- Anti-Invisible
- Anti-Change Speed
- Anti-Free Camera
- Anti-Plate Changer
- Anti-Night Vision
- Anti-Thermal Vision
- Anti-Super Jump
- Anti-Suicide

**Server Side Protection**

- Anti-Spam Chat
- Anti-Blacklist Commands
- Anti-Weapon Damage Changer
- Anti-Vehicle Damage Changer
- Anti-Blacklist Word
- Anti-Bring All
- Anti-Blacklist Trigger
- Anti-Spam Trigger
- Anti-Clear Ped Tasks
- Anti-Taze Players
- Anti-Inject
- Anti-Blacklist Explosion
- Anti-Explosion Spam
- Anti-Blacklist Object
- Anti-Blacklist Ped
- Anti-Blacklist Vehicle
- Anti-Spam Vehicle
- Anti-Spam Ped
- Anti-Spam Object
- Anti-Change Perm
- Anti-Play Sound

---

### Inject Protection

**Server Side Protection**

- Anti-Resource Start/Stop/Restart
- Anti-Add Command

---

### Connection Protection

**Server Side Protection**

- Anti-VPN
- Anti-Hosting
- Anti-Blacklist Name

---

### Ban Method

**Identifiers**

- FiveM License
- Steam Identifier
- IP Address
- Microsoft ID (LIVE ID)
- Xbox Live ID (XBL ID)
- Discord ID
- FiveM Player Tokens

---

### Logs

- Console
- Discord
- Chat
- Screenshot

---

### Installation

Add the following lines to your `server.cfg`:

```
ensure FIREAC
ensure screenshot-basic
ensure discord-screenshot
```

---

### Whitelist

To manage authorized users, utilize the admin menu in-game..

---

### Exports (Server Side)

- `FIREAC_CHANGE_TEMP_WHITELIST`: This export enables you to add or remove a player from the `Temporary Whitelist`s. For example:

```lua
-- Add:
exports['FIREAC']:FIREAC_CHANGE_TEMP_WHITELIST(source, true)

-- Remove:
exports['FIREAC']:FIREAC_CHANGE_TEMP_WHITELIST(source, false)
```

- `FIREAC_CHECK_TEMP_WHITELIST`: This export is exclusively for checking a player's status in the `Temporary Whitelist`:
  for example :

```
-- Check:
exports['FIREAC']:FIREAC_CHECK_TEMP_WHITELIST(source)
```

- `FIREAC_ACTION`: Use this export for performing actions like `BAN`,`KICK`, or `WARN` on a player:

```
-- Ban:
exports['FIREAC']:FIREAC_ACTION(source, "BAN", reason, details)

-- Kick:
exports['FIREAC']:FIREAC_ACTION(source, "KICK", reason, details)

-- Warn:
exports['FIREAC']:FIREAC_ACTION(source, "WARN", reason, details)
```

### (Client Side)

- `FIREAC_CHANGE_TEMP_WHHITELIST`: This export is designed for adding or removing a player from the `Temporary Whitelist` on the client side:

```
-- Add:
exports['FIREAC']:FIREAC_CHANGE_TEMP_WHHITELIST(true)

-- Remove:
exports['FIREAC']:FIREAC_CHANGE_TEMP_WHHITELIST(false)
```

- `FIREAC_CHECK_TEMP_WHITELIST`: Similar to the server side, use this export to check a player's status in the `Temporary Whitelist`:

```
-- Check:
exports['FIREAC']:FIREAC_CHECK_TEMP_WHITELIST()
```

- `FIREAC_ACTION`: On the client side, employ this export for actions such as `BAN`, `KICK`, or `WARN`:

```
-- Ban:
exports['FIREAC']:FIREAC_ACTION("BAN", reason, details)

-- Kick:
exports['FIREAC']:FIREAC_ACTION("KICK", reason, details)

-- Warn:
exports['FIREAC']:FIREAC_ACTION("WARN", reason, details)
```

---

### Command

| Command                                 | Description                                                                                       |
| --------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `/funban [Ban ID]`                      | Unban a user from the database by admins (use the console in-game).                               |
| `/addadmin [ID (Player in server)]`     | Add an admin to the database, granting access to the admin menu (use the console in-game).        |
| `/addwhitelist [ID (Player in server)]` | Add an admin to the database, providing full permissions in the server (use the console in-game). |

---

### Tutorial

For a step-by-step guide on installing the anti-cheat, refer to the FIREAC website tutorial at **https://amirrezajaberi.ir/fireac**.

---

### License

<table>
  <tr>
    <td>
      <h4 align='center'>Legal Notices</h4>
    </td>
  </tr>
  <tr>
    <td>
      FIREAC - AGPL-3.0 License
      <br>
      Copyright © 2022-2023 by Amirreza Jaberi
      <br>
      This software is licensed under the terms of the GNU Affero General Public License as published by
      the Free Software Foundation, either version 3 of the License, or
      (at your option) any later version.
      <br><br>
      <strong>Disclaimer:</strong>
      <br>
      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
      GNU Affero General Public License for more details.
      <br><br>
      <strong>Copy of the License:</strong>
      <br>
      You should have received a copy of the GNU Affero General Public License
      along with this program.
      If not, see <a href="https://www.gnu.org/licenses/">https://www.gnu.org/licenses/</a>.
    </td>
  </tr>
</table>
