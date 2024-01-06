-- FIREAC Configuration
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0

FIREAC              = {}

-- FIREAC Version
FIREAC.Version      = "7.1.0"

-- Server Configuration
FIREAC.ServerConfig = {
    -- Server Name: Set your server name here.
    -- Example: Name = "My Awesome Server"
    Name  = "YOUR SERVER NAME",

    -- Server Port: Enter your server port here.
    -- Example: Port = "30120"
    Port  = "30120",

    -- Operating System: If your OS is Linux, set this to true; otherwise, keep it false.
    -- Example: Linux = true
    Linux = false
}


-- Chat Settings
FIREAC.ChatSettings             = {
    Enable      = true, -- Enable chat features
    PrivateWarn = true  -- Warn players for private messages
}

-- Screenshot Settings
FIREAC.ScreenShot               = {
    Enable  = true,  -- Enable screenshot feature
    Format  = "PNG", -- Screenshot format
    Quality = 1      -- Screenshot quality
}

-- Connection Settings
FIREAC.Connection               = {
    AntiBlackListName = true, -- Anti-blacklist server name
    AntiVPN           = true, -- Anti-VPN
    HideIP            = true  -- Hide player's IP
}

-- Spawn Settings
FIREAC.Spawn                    = {
    LongSpawnMode = true -- Enable long spawn mode
}

-- Message Settings
FIREAC.Message                  = {
    Kick = "⚡️ You've been kicked from the server protection by FIREAC®. Avoid cheating on this server.",
    Ban  = "⛔️ You've been banned from the server. Please create a support ticket for assistance.",
}

-- Admin Menu Settings
FIREAC.AdminMenu                = {
    Enable         = true, -- Enable admin menu
    Key            = "F9", -- Admin menu activation key
    MenuPunishment = "BAN" -- Punishment for unauthorized access
}

-- Anti-Track Player Settings
FIREAC.AntiTrackPlayer          = false
FIREAC.MaxTrack                 = 10
FIREAC.TrackPunishment          = "WARN"

-- Anti-Health Hack Settings
FIREAC.AntiHealthHack           = true
FIREAC.MaxHealth                = 200
FIREAC.HealthPunishment         = "BAN"

-- Anti-Armor Hack Settings
FIREAC.AntiArmorHack            = true
FIREAC.MaxArmor                 = 100
FIREAC.ArmorPunishment          = "BAN"

-- Anti-Blacklist Tasks Settings
FIREAC.AntiBlacklistTasks       = true
FIREAC.TasksPunishment          = "BAN"

-- Anti-Blacklist Anims Settings
FIREAC.AntiBlacklistAnims       = true
FIREAC.AnimsPunishment          = "BAN"

-- Safe Players Settings
FIREAC.SafePlayers              = true
FIREAC.AntiInfinityAmmo         = true

-- Anti-Spectate Settings
FIREAC.AntiSpectate             = true
FIREAC.SpactatePunishment       = "BAN"

-- Anti-BlackList Weapon Settings
FIREAC.AntiBlackListWeapon      = true
FIREAC.AntiAddWeapon            = true
FIREAC.AntiRemoveWeapon         = true
FIREAC.AntiWeaponsExplosive     = true
FIREAC.WeaponPunishment         = "BAN"

-- Anti-God Mode Settings
FIREAC.AntiGodMode              = true
FIREAC.GodPunishment            = "BAN"

-- Anti-Invisible Settings
FIREAC.AntiInvisible            = true
FIREAC.InvisiblePunishment      = "KICK"

-- Anti-Change Speed Settings
FIREAC.AntiChangeSpeed          = true
FIREAC.SpeedPunishment          = "KICK"

-- Anti-Free Cam Settings
FIREAC.AntiFreeCam              = false
FIREAC.CamPunishment            = "BAN"

-- Anti-Rainbow Vehicle Settings
FIREAC.AntiRainbowVehicle       = true
FIREAC.RainbowPunishment        = "BAN"

-- Anti-Plate Changer Settings
FIREAC.AntiPlateChanger         = true
FIREAC.AntiBlackListPlate       = true
FIREAC.PlatePunishment          = "BAN"

-- Anti-Vision Settings
FIREAC.AntiNightVision          = true
FIREAC.AntiThermalVision        = true
FIREAC.VisionPunishment         = "BAN"

-- Anti-Super Jump Settings
FIREAC.AntiSuperJump            = true
FIREAC.JumpPunishment           = "BAN"

-- Anti-Teleport Settings
FIREAC.AntiTeleport             = true
FIREAC.MaxFootDistance          = 200
FIREAC.MaxVehicleDistance       = 600
FIREAC.TeleportPunishment       = "BAN"

-- Anti-Noclip Settings
FIREAC.AntiNoclip               = false
FIREAC.NoclipPunishment         = "KICK"

-- Anti-Ped Changer Settings
FIREAC.AntiPedChanger           = true
FIREAC.PedChangePunishment      = "BAN"

-- Anti-Infinite Stamina Settings
FIREAC.AntiInfiniteStamina      = false
FIREAC.InfinitePunishment       = "WARN"

-- Anti-Ragdoll Settings
FIREAC.AntiRagdoll              = false
FIREAC.RagdollPunishment        = "WARN"

-- Anti-Menyoo Settings
FIREAC.AntiMenyoo               = false
FIREAC.MenyooPunishment         = "WARN"

-- Anti-Aim Assist Settings
FIREAC.AntiAimAssist            = false
FIREAC.AimAssistPunishment      = "WARN"

-- Anti-Resource Stopper Settings
FIREAC.AntiResourceStopper      = true
FIREAC.AntiResourceStarter      = false
FIREAC.AntiResourceRestarter    = false
FIREAC.ResourcePunishment       = "WARN"

-- Anti-Tiny Ped Settings
FIREAC.AntiTinyPed              = true
FIREAC.PedFlagPunishment        = "BAN"

-- Anti-Suicide Settings
FIREAC.AntiSuicide              = false
FIREAC.SuicidePunishment        = "WARN"

-- Anti-Pickup Collect Settings
FIREAC.AntiPickupCollect        = true
FIREAC.PickupPunishment         = "BAN"

-- Anti-Spam Chat Settings
FIREAC.AntiSpamChat             = true
FIREAC.MaxMessage               = 10
FIREAC.CoolDownSec              = 3
FIREAC.ChatPunishment           = "BAN"

-- Anti-BlackList Commands Settings
FIREAC.AntiBlackListCommands    = true
FIREAC.CMDPunishment            = "BAN"

-- Anti-Change Damage Settings
FIREAC.AntiWeaponDamageChanger  = true
FIREAC.AntiVehicleDamageChanger = true
FIREAC.DamagePunishment         = "BAN"

-- Anti-BlackList Word Settings
FIREAC.AntiBlackListWord        = true
FIREAC.WordPunishment           = "KICK"

-- Anti-Bring All Settings
FIREAC.AntiBringAll             = true
FIREAC.BringAllPunishment       = "BAN"

-- Anti-Trigger Settings
FIREAC.AntiBlackListTrigger     = true
FIREAC.AntiSpamTrigger          = true
FIREAC.TriggerPunishment        = "BAN"

-- Anti-Clear Ped Tasks Settings
FIREAC.AntiClearPedTasks        = true
FIREAC.MaxClearPedTasks         = 5
FIREAC.CPTPunishment            = "BAN"

-- Anti-Taze Players Settings
FIREAC.AntiTazePlayers          = true
FIREAC.MaxTazeSpam              = 3
FIREAC.TazePunishment           = "KICK"

-- Anti-Inject Settings
FIREAC.AntiInject               = false
FIREAC.InjectPunishment         = "BAN"

-- Anti-Explosion Settings
FIREAC.AntiBlackListExplosion   = true
FIREAC.AntiExplosionSpam        = true
FIREAC.MaxExplosion             = 10
FIREAC.ExplosionSpamPunishment  = "BAN"

-- Anti-Entity Spawn Settings
FIREAC.AntiBlackListObject      = true
FIREAC.AntiBlackListPed         = true
FIREAC.AntiBlackListBuilding    = true
FIREAC.AntiBlackListVehicle     = true
FIREAC.EntityPunishment         = "BAN"

-- Anti-NPC Spawn Settings
FIREAC.AntiSpawnNPC             = false

-- Anti-Spam Entity Settings
FIREAC.AntiSpamVehicle          = true
FIREAC.MaxVehicle               = 10

FIREAC.AntiSpamPed              = true
FIREAC.MaxPed                   = 4

FIREAC.AntiSpamObject           = true
FIREAC.MaxObject                = 15

FIREAC.SpamPunishment           = "KICK"

-- Anti-Change Permission Settings
FIREAC.AntiChangePerm           = true
FIREAC.PermPunishment           = "BAN"

-- Anti-Play Sound Settings
FIREAC.AntiPlaySound            = true
FIREAC.SoundPunishment          = "KICK"
