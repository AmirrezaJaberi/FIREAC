
--------[-----------------------------------]--------
--------[-----------------------------------]--------
--------[---- Copyright 2022 by FIREAC® ----]--------
--------[-----------------------------------]--------
--------[------ Dev By AmIrReZa#2080 -------]--------
--------[-----------------------------------]--------



FIREAC = {}
--                                           * 𝗧𝗜𝗣 𝟭 *
--                               𝗧𝘆𝗽𝗲 𝗼𝗳 𝗽𝘂𝗻𝗶𝘀𝗵𝗺𝗲𝗻𝘁𝘀 : BAN | KICK | WARN
--
--                                           * 𝗧𝗜𝗣 𝟮 *
--                                           𝗦𝗰𝗿𝗲𝗲𝗻𝘀𝗵𝗼𝘁
--                              𝗙𝗼𝗿 𝗘𝗻𝗮𝗯𝗹𝗲 𝗦𝗰𝗿𝗲𝗲𝗻𝘀𝗵𝗼𝘁 𝗼𝗽𝘁𝗶𝗼𝗻 𝗱𝗼𝘄𝗻𝗹𝗼𝗮𝗱 𝘁𝗵𝗶𝘀
--   (https://github.com/jaimeadf/discord-screenshot/releases/download/1.3.6/discord-screenshot-1.3.6.zip)
--                                𝗔𝗗𝗗 𝟭 𝗥𝗘𝗦𝗢𝗨𝗥𝗖𝗘 𝗢𝗡 𝗬𝗢𝗨𝗥 𝗦𝗘𝗥𝗩𝗘𝗥

--【 𝗩𝗲𝗿𝘀𝗶𝗼𝗻 𝗖𝗵𝗲𝗰𝗸 𝗳𝗼𝗿 𝘂𝗽𝗱𝗮𝘁𝗲𝘀 】--
FIREAC.Version   = 6.1
FIREAC.Port      = "30120"

--【 𝗟𝗼𝗴 𝗙𝗼𝗿 𝗦𝗲𝗻𝗱 𝗶𝗻 𝗗𝗶𝘀𝗰𝗼𝗿𝗱 】--
FIREAC.Log = {
    Ban        = "",
    Connect    = "",
    Disconnect = "",
    Exoplosion = "",
    Error      = ""
}

--【 𝗦𝗰𝗿𝗲𝗲𝗻𝗦𝗵𝗼𝘁 】--  (𝗧𝗜𝗣 𝟮)
FIREAC.ScreenShot = {
    Enable  = true,
    Format  = "PNG",
    Quality = 1,
    Log     = ""
}

--【 𝗖𝗼𝗻𝗻𝗲𝗰𝘁𝗶𝗼𝗻 𝗦𝗲𝘁𝘁𝗶𝗻𝗴𝘀 】--
FIREAC.Connection = {
    AntiBlackListName = true,
    AntiVPN           = true,
    Log               = ""
}

--【 𝗠𝗲𝘀𝘀𝗮𝗴𝗲 】--
FIREAC.Message = {
    Kick = "You Are ⚡️ Kicked From Server Protection By FIREAC® Don't Try For Cheat in this server",
    Ban  = "You Are ⛔️ Banned Form Server Please Make Ticket in FIREAC® https://discord.gg/8zGyDhtbcg",
}

--【 𝗔𝗱𝗺𝗶𝗻 𝗠𝗲𝗻𝘂 】--
FIREAC.AdminMenu = {
    Enable         = true,
    Key            = "INSERT",
    MenuPunishment = "WARN"
}

--【 𝗔𝗻𝘁𝗶 𝗧𝗿𝗮𝗰𝗸 𝗣𝗹𝗮𝘆𝗲𝗿 】--
FIREAC.AntiTrackPlayer = true
FIREAC.MaxTrack        = 10
FIREAC.TrackPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗛𝗲𝗮𝗹𝘁𝗵 𝗛𝗮𝗰𝗸 】--
FIREAC.AntiHealthHack   = true
FIREAC.MaxHealth        = 200
FIREAC.HealthPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗔𝗿𝗺𝗼𝗿 𝗛𝗮𝗰𝗸 】--
FIREAC.AntiArmorHack   = true
FIREAC.MaxArmor        = 100
FIREAC.ArmorPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗮𝘀𝗸𝘀 】--
FIREAC.AntiBlacklistTasks = true
FIREAC.TasksPunishment    = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗣𝗹𝗮𝘆 𝗔𝗻𝗶𝗺𝘀 】--
FIREAC.AntiBlacklistAnims = true
FIREAC.AnimsPunishment    = "WARN"

--【 𝗦𝗮𝗳𝗲 𝗣𝗹𝗮𝘆𝗲𝗿𝘀 】--
FIREAC.SafePlayers      = true
FIREAC.AntiInfinityAmmo = true

--【 𝗔𝗻𝘁𝗶 𝗦𝗽𝗲𝗰𝘁𝗮𝘁𝗲 】--
FIREAC.AntiSpactate       = true
FIREAC.SpactatePunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗪𝗲𝗮𝗽𝗼𝗻 】--
FIREAC.AntiBlackListWeapon  = true
FIREAC.AntiAddWeapon        = true
FIREAC.AntiRemoveWeapon     = true
FIREAC.AntiWeaponsExplosive = true
FIREAC.WeaponPunishment     = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗚𝗼𝗱𝗠𝗼𝗱𝗲 】--
FIREAC.AntiGodMode    = true
FIREAC.GodPunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗜𝗻𝘃𝗶𝘀𝗶𝗯𝗹𝗲 】--
FIREAC.AntiInvisble         = true
FIREAC.InvisiblePunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗦𝗽𝗲𝗲𝗱 】--
FIREAC.AntiChangeSpeed = true
FIREAC.SpeedPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗙𝗿𝗲𝗲 𝗖𝗮𝗺 】--
FIREAC.AntiFreeCam   = false
FIREAC.CamPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗥𝗮𝗶𝗻𝗯𝗼𝘄 𝗩𝗲𝗵𝗶𝗰𝗹𝗲 】--
FIREAC.AntiRainbowVehicle  = true
FIREAC.RainbowPunishment   = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗔𝗶𝗺 𝗕𝗼𝘁 】--
FIREAC.AntiAimBot       = false
FIREAC.AimBotPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗣𝗹𝗮𝘁𝗲 】--
FIREAC.AntiPlateChanger   = true
FIREAC.AntiBlackListPlate = true
FIREAC.PlatePunishment    = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗩𝗶𝘀𝗶𝗼𝗻 】--
FIREAC.AntiNightVision   = true
FIREAC.AntiThermalVision = true
FIREAC.VisionPunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗦𝘂𝗽𝗲𝗿 𝗝𝘂𝗺𝗽 】--
FIREAC.AntiSuperJump  = true
FIREAC.JumpPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗲𝗹𝗲𝗽𝗼𝗿𝘁 】--
FIREAC.AntiTeleport        = true
FIREAC.MaxFootDistence     = 200
FIREAC.MaxVehicleDistence  = 600
FIREAC.TeleportPunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗣𝗲𝗱 𝗖𝗵𝗮𝗻𝗴𝗲𝗿 】--
FIREAC.AntiPedChanger       = true
FIREAC.PedChangePunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗜𝗻𝗳𝗶𝗻𝗶𝘁𝗲 𝗦𝘁𝗮𝗺𝗶𝗻𝗮 】--
FIREAC.AntiInfiniteStamina    = true
FIREAC.InfinitePunishment     = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗥𝗮𝗴𝗱𝗼𝗹𝗹 】--
FIREAC.AntiRagdoll           =  true
FIREAC.RagdollPunishment     = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗠𝗲𝗻𝘆𝗼𝗼 】--
FIREAC.AntiMenyoo           =  false
FIREAC.MenyooPunishment     = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗔𝗶𝗺 𝗔𝘀𝘀𝗶𝘀𝘁 】--
FIREAC.AntiAimAssist        =  false
FIREAC.AimAssistPunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
FIREAC.AntiResourceStoper     = false
FIREAC.AntiResourceStarter    = false
FIREAC.AntiResourceRestarter  = false
FIREAC.ResourcePunishment     = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗙𝗹𝗮𝗴 】--
FIREAC.AntiTinyPed        = true
FIREAC.PedFlagPunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗦𝘂𝗶𝗰𝗶𝗱𝗲 】--
FIREAC.AntiSuicide   = false
FIREAC.SuiPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗼𝗹𝗹𝗲𝗰𝘁𝗲𝗱 𝗣𝗶𝗰𝗸𝘂𝗽 】--
FIREAC.AntiCollectedPickup = true
FIREAC.PickupePunishment   = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝘁 】--
FIREAC.AntiSpamChat          = true
FIREAC.MaxMessage            = 10
FIREAC.CoolDownSec           = 3
FIREAC.ChatPunishment        = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗼𝗺𝗺𝗮𝗻𝗱 】--
FIREAC.AntiBlackListCommands = true
FIREAC.CMDPunishment         = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗗𝗮𝗺𝗮𝗴𝗲 】--
FIREAC.AntiWeaponDamageChanger   = true
FIREAC.AntiVehicleDamageChanger  = true
FIREAC.DamagePunishment          = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗪𝗼𝗿𝗱 】--
FIREAC.AntiBlackListWord   = true
FIREAC.WordPunishment      = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗕𝗿𝗶𝗻𝗴 𝗔𝗹𝗹 】--
FIREAC.AntiBringAll       = true
FIREAC.BringAllPunishment = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗿𝗶𝗴𝗴𝗲𝗿 】--
FIREAC.AntiBlackListTrigger = true
FIREAC.AntiSpamTrigger      = true
FIREAC.TriggerPunishment    = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗹𝗲𝗮𝗿 𝗣𝗲𝗱 𝗧𝗮𝘀𝗸𝘀 】--
FIREAC.AntiClearPedTasks   = true
FIREAC.MaxClearPedTasks    = 5
FIREAC.CPTPunishment       = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗧𝗮𝘇𝗲 𝗣𝗹𝗮𝘆𝗲𝗿𝘀 】--
FIREAC.AntiTazePlayers = true
FIREAC.MaxTazeSpam     = 3
FIREAC.TazePunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗜𝗻𝗷𝗲𝗰𝘁 】--
FIREAC.AntiInject        = true
FIREAC.InjectPunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗘𝘅𝗽𝗹𝗼𝘀𝗶𝗼𝗻 】--
FIREAC.AntiBlackListExplosion   = true
FIREAC.AntiExplosionSpam        = true
FIREAC.MaxExplosion             = 10
FIREAC.ExplosionSpamPunishment  = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗘𝗻𝘁𝗶𝘁𝘆 𝗦𝗽𝗮𝘄𝗻𝗲𝗿 】--
FIREAC.AntiBlackListObject   = true
FIREAC.AntiBlackListPed      = true
FIREAC.AntiBlackListBuilding = true
FIREAC.AntiBlackListVehicle  = true
FIREAC.EntityPunishment      = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗘𝗻𝘁𝗶𝘁𝘆 𝗦𝗽𝗮𝗺𝗲𝗿 】--
FIREAC.AntiSpawnNPC      = false

FIREAC.AntiSpamVehicle   = true
FIREAC.MaxVehicle        = 10

FIREAC.AntiSpamPed       = true
FIREAC.MaxPed            = 4

FIREAC.AntiSpamObject    = true
FIREAC.MaxObject         = 15

FIREAC.SpamPunishment    = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗖𝗵𝗮𝗻𝗴𝗲 𝗣𝗲𝗿𝗺 】--
FIREAC.AntiChangePerm    = true
FIREAC.PermPunishment    = "WARN"

--【 𝗔𝗻𝘁𝗶 𝗣𝗹𝗮𝘆 𝗦𝗼𝘂𝗻𝗱 】--
FIREAC.AntiPlaySound    = true
FIREAC.SoundPunishment  = "WARN"