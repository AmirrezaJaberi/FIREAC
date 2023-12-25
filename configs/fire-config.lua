--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

FIREAC                          = {}
--                                           * 𝗧𝗜𝗣 𝟭 *
--                               Type of Punishment : BAN | KICK | WARN
--
--                                           * 𝗧𝗜𝗣 𝟮 *
--                                           Screenshot
--                            For enable screenshot download this resources
--                     (https://github.com/jaimeadf/discord-screenshot/releases)
--                                 Add this resource to your server

--【 𝗩𝗲𝗿𝘀𝗶𝗼𝗻 𝗖𝗵𝗲𝗰𝗸 】--
FIREAC.Version                  = "7.0.0"

--【 𝗦𝗲𝗿𝘃𝗲𝗿 𝗦𝗲𝘁𝘁𝗶𝗻𝗴𝘀 】--
FIREAC.ServerConfig             = {
    Name = "YOUR SERVER NAME",
    Port = "30120",
}

--【 𝗖𝗵𝗮𝘁 𝗦𝗲𝘁𝘁𝗶𝗻𝗴𝘀 】--
FIREAC.ChatSettings             = {
    Enable      = true,
    PrivateWarn = true,
}

--【 𝗦𝗰𝗿𝗲𝗲𝗻𝗦𝗵𝗼𝘁 】--
FIREAC.ScreenShot               = {
    Enable  = true,
    Format  = "PNG",
    Quality = 1,
}

--【 𝗖𝗼𝗻𝗻𝗲𝗰𝘁𝗶𝗼𝗻 𝗦𝗲𝘁𝘁𝗶𝗻𝗴𝘀 】--
FIREAC.Connection               = {
    AntiBlackListName = true,
    AntiVPN           = true,
    HideIP            = true,
}

--【 𝗦𝗽𝗮𝘄𝗻 】--
FIREAC.Spawn                    = {
    LongSpawnMode = true
}

--【 𝗠𝗲𝘀𝘀𝗮𝗴𝗲 】--
FIREAC.Message                  = {
    Kick = "You Are ⚡️ Kicked From Server Protection By FIREAC® Don't Try For Cheat in this Server",
    Ban  = "You Are ⛔️ Banned Form Server Please Make Ticket in Our Server ",
}

--【 𝗔𝗱𝗺𝗶𝗻 𝗠𝗲𝗻𝘂 】--
FIREAC.AdminMenu                = {
    Enable         = true,
    Key            = "F9",
    MenuPunishment = "BAN",
}

--【 𝗔𝗻𝘁𝗶 𝗧𝗿𝗮𝗰𝗸 𝗣𝗹𝗮𝘆𝗲𝗿 】--
FIREAC.AntiTrackPlayer          = false
FIREAC.MaxTrack                 = 10
FIREAC.TrackPunishment          = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗛𝗲𝗮𝗹𝘁𝗵 𝗛𝗮𝗰𝗸 】--
FIREAC.AntiHealthHack           = true
FIREAC.MaxHealth                = 200
FIREAC.HealthPunishment         = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗔𝗿𝗺𝗼𝗿 𝗛𝗮𝗰𝗸 】--
FIREAC.AntiArmorHack            = true
FIREAC.MaxArmor                 = 100
FIREAC.ArmorPunishment          = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗮𝘀𝗸𝘀 】--
FIREAC.AntiBlacklistTasks       = true
FIREAC.TasksPunishment          = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗣𝗹𝗮𝘆 𝗔𝗻𝗶𝗺𝘀 】--
FIREAC.AntiBlacklistAnims       = true
FIREAC.AnimsPunishment          = "BAN"

--【 𝗦𝗮𝗳𝗲 𝗣𝗹𝗮𝘆𝗲𝗿𝘀 】--
FIREAC.SafePlayers              = true
FIREAC.AntiInfinityAmmo         = true

--【 𝗔𝗻𝘁𝗶 𝗦𝗽𝗲𝗰𝘁𝗮𝘁𝗲 】--
FIREAC.AntiSpectate             = true
FIREAC.SpactatePunishment       = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗪𝗲𝗮𝗽𝗼𝗻 】--
FIREAC.AntiBlackListWeapon      = true
FIREAC.AntiAddWeapon            = true
FIREAC.AntiRemoveWeapon         = true
FIREAC.AntiWeaponsExplosive     = true
FIREAC.WeaponPunishment         = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗚𝗼𝗱𝗠𝗼𝗱𝗲 】--
FIREAC.AntiGodMode              = true
FIREAC.GodPunishment            = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗜𝗻𝘃𝗶𝘀𝗶𝗯𝗹𝗲 】--
FIREAC.AntiInvisible            = true
FIREAC.InvisiblePunishment      = "KICK"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗦𝗽𝗲𝗲𝗱 】--
FIREAC.AntiChangeSpeed          = true
FIREAC.SpeedPunishment          = "KICK"

--【 𝗔𝗻𝘁𝗶 𝗙𝗿𝗲𝗲 𝗖𝗮𝗺 】--
FIREAC.AntiFreeCam              = false
FIREAC.CamPunishment            = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗥𝗮𝗶𝗻𝗯𝗼𝘄 𝗩𝗲𝗵𝗶𝗰𝗹𝗲 】--
FIREAC.AntiRainbowVehicle       = true
FIREAC.RainbowPunishment        = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗣𝗹𝗮𝘁𝗲 】--
FIREAC.AntiPlateChanger         = true
FIREAC.AntiBlackListPlate       = true
FIREAC.PlatePunishment          = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗩𝗶𝘀𝗶𝗼𝗻 】--
FIREAC.AntiNightVision          = true
FIREAC.AntiThermalVision        = true
FIREAC.VisionPunishment         = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗦𝘂𝗽𝗲𝗿 𝗝𝘂𝗺𝗽 】--
FIREAC.AntiSuperJump            = true
FIREAC.JumpPunishment           = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗲𝗹𝗲𝗽𝗼𝗿𝘁 】--
FIREAC.AntiTeleport             = true
FIREAC.MaxFootDistance          = 200
FIREAC.MaxVehicleDistance       = 600
FIREAC.TeleportPunishment       = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗡𝗼𝗰𝗹𝗶𝗽 】--
FIREAC.AntiNoclip               = false
FIREAC.NoclipPunishment         = "KICK"

--【 𝗔𝗻𝘁𝗶 𝗣𝗲𝗱 𝗖𝗵𝗮𝗻𝗴𝗲𝗿 】--
FIREAC.AntiPedChanger           = true
FIREAC.PedChangePunishment      = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗜𝗻𝗳𝗶𝗻𝗶𝘁𝗲 𝗦𝘁𝗮𝗺𝗶𝗻𝗮 】--
FIREAC.AntiInfiniteStamina      = false
FIREAC.InfinitePunishment       = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗥𝗮𝗴𝗱𝗼𝗹𝗹 】--
FIREAC.AntiRagdoll              = false
FIREAC.RagdollPunishment        = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗠𝗲𝗻𝘆𝗼𝗼 】--
FIREAC.AntiMenyoo               = false
FIREAC.MenyooPunishment         = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗔𝗶𝗺 𝗔𝘀𝘀𝗶𝘀𝘁 】--
FIREAC.AntiAimAssist            = false
FIREAC.AimAssistPunishment      = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
FIREAC.AntiResourceStopper      = true
FIREAC.AntiResourceStarter      = false
FIREAC.AntiResourceRestarter    = false
FIREAC.ResourcePunishment       = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗙𝗹𝗮𝗴 】--
FIREAC.AntiTinyPed              = true
FIREAC.PedFlagPunishment        = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗦𝘂𝗶𝗰𝗶𝗱𝗲 】--
FIREAC.AntiSuicide              = false
FIREAC.SuicidePunishment        = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗼𝗹𝗹𝗲𝗰𝘁𝗲𝗱 𝗣𝗶𝗰𝗸𝘂𝗽 】--
FIREAC.AntiPickupCollect        = true
FIREAC.PickupPunishment         = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝘁 】--
FIREAC.AntiSpamChat             = true
FIREAC.MaxMessage               = 10
FIREAC.CoolDownSec              = 3
FIREAC.ChatPunishment           = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗼𝗺𝗺𝗮𝗻𝗱 】--
FIREAC.AntiBlackListCommands    = true
FIREAC.CMDPunishment            = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗗𝗮𝗺𝗮𝗴𝗲 】--
FIREAC.AntiWeaponDamageChanger  = true
FIREAC.AntiVehicleDamageChanger = true
FIREAC.DamagePunishment         = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗪𝗼𝗿𝗱 】--
FIREAC.AntiBlackListWord        = true
FIREAC.WordPunishment           = "KICK"

--【 𝗔𝗻𝘁𝗶 𝗕𝗿𝗶𝗻𝗴 𝗔𝗹𝗹 】--
FIREAC.AntiBringAll             = true
FIREAC.BringAllPunishment       = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗿𝗶𝗴𝗴𝗲𝗿 】--
FIREAC.AntiBlackListTrigger     = true
FIREAC.AntiSpamTrigger          = true
FIREAC.TriggerPunishment        = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗹𝗲𝗮𝗿 𝗣𝗲𝗱 𝗧𝗮𝘀𝗸𝘀 】--
FIREAC.AntiClearPedTasks        = true
FIREAC.MaxClearPedTasks         = 5
FIREAC.CPTPunishment            = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗮𝘇𝗲 𝗣𝗹𝗮𝘆𝗲𝗿𝘀 】--
FIREAC.AntiTazePlayers          = true
FIREAC.MaxTazeSpam              = 3
FIREAC.TazePunishment           = "KICK"

--【 𝗔𝗻𝘁𝗶 𝗜𝗻𝗷𝗲𝗰𝘁 】--
FIREAC.AntiInject               = false
FIREAC.InjectPunishment         = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗘𝘅𝗽𝗹𝗼𝘀𝗶𝗼𝗻 】--
FIREAC.AntiBlackListExplosion   = true
FIREAC.AntiExplosionSpam        = true
FIREAC.MaxExplosion             = 10
FIREAC.ExplosionSpamPunishment  = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗘𝗻𝘁𝗶𝘁𝘆 𝗦𝗽𝗮𝘄𝗻𝗲𝗿 】--
FIREAC.AntiBlackListObject      = true
FIREAC.AntiBlackListPed         = true
FIREAC.AntiBlackListBuilding    = true
FIREAC.AntiBlackListVehicle     = true
FIREAC.EntityPunishment         = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗘𝗻𝘁𝗶𝘁𝘆 𝗦𝗽𝗮𝗺𝗲𝗿 】--
FIREAC.AntiSpawnNPC             = false

FIREAC.AntiSpamVehicle          = true
FIREAC.MaxVehicle               = 10

FIREAC.AntiSpamPed              = true
FIREAC.MaxPed                   = 4

FIREAC.AntiSpamObject           = true
FIREAC.MaxObject                = 15

FIREAC.SpamPunishment           = "KICK"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗣𝗲𝗿𝗺 】--
FIREAC.AntiChangePerm           = true
FIREAC.PermPunishment           = "BAN"

--【 𝗔𝗻𝘁𝗶 𝗣𝗹𝗮𝘆 𝗦𝗼𝘂𝗻𝗱 】--
FIREAC.AntiPlaySound            = true
FIREAC.SoundPunishment          = "KICK"
