-- FIREAC Configuration
-- Copyright 2022-2026 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0

FIREAC              = {}

FIREAC.Version      = "7.2.18"

FIREAC.ServerConfig = {
    Name  = "YOUR SERVER NAME",

    Port  = "30120",

    Linux = false
}

FIREAC.ACE = {
    Enable = false,
    Admin = "FIREAC.Admin",
    Whitelist = "FIREAC.Whitelist",
    Unban = "FIREAC.Unban"
}

FIREAC.ChatSettings             = {
    Enable      = true,
    PrivateWarn = true
}

FIREAC.ScreenShot               = {
    Enable  = true,
    Format  = "PNG",
    Quality = 1
}

FIREAC.Connection               = {
    AntiBlackListName = true,
    AntiVPN           = false,
    HideIP            = true,

    UseDeferrals      = true,
    DeferralMode      = "card",
    DeferralDelayMs   = 1200,
    DeferralStepMs    = 120,
    AdaptiveCard      = true,

    ShowConnectUI     = true,
    ShowProblemCard   = true,
    ProblemOnlyMode   = false,

    PresentCardOnce   = false,
    PresentCardHoldMs = 900,
    CardTitle         = "FIREAC SECURITY",
    VisualStepMs      = 320,
    ConnectHoldMs     = 1200
}

FIREAC.ServerRuntime            = {
    EntityCreatedMonitor = false,
    EntityCreatedDelayMs = 750
}

FIREAC.Detection = {
    RequirePlayerSpawned = true,
    RequireFrameworkLoaded = true,
    ReadyMaxWaitMs = 120000,
    MinimumClientReadyMs = 12000,
    ResourceRestartAssumeSpawnedMs = 8000,

    SpawnGraceMs = 20000,
    PostSpawnSettleMs = 18000,
    PostReadyGraceMs = 20000,
    FrameworkLoadGraceMs = 12000,
    RespawnGraceMs = 15000,
    PedChangeGraceMs = 12000,
    CameraGraceMs = 3500,
    GodmodeAfterReadyMs = 12000,

    EvidenceThreshold = 3,
    EvidenceWindowMs = 15000,
    GodmodeSamples = 6,
    ClientReportCooldownMs = 10000,
    ServerReportWindowMs = 10000,
    ServerReportLimit = 6
}

FIREAC.Message                  = {
    Kick = "⚡️ You've been kicked from the server protection by FIREAC®. Avoid cheating on this server.",
    Ban  = "⛔️ You've been banned from the server. Please create a support ticket for assistance.",
}

FIREAC.AdminMenu                = {
    Enable         = true,
    Key            = "F9",
    MenuPunishment = "BAN"
}

FIREAC.AntiHealthHack           = true
FIREAC.MaxHealth                = 200
FIREAC.HealthPunishment         = "BAN"

FIREAC.AntiArmorHack            = true
FIREAC.MaxArmor                 = 100
FIREAC.ArmorPunishment          = "BAN"

FIREAC.AntiBlacklistTasks       = false
FIREAC.TasksPunishment          = "BAN"

FIREAC.AntiBlacklistAnims       = true
FIREAC.AnimsPunishment          = "BAN"

FIREAC.AntiInfinityAmmo         = true

FIREAC.AntiSpectate             = true
FIREAC.SpactatePunishment       = "BAN"
FIREAC.SpectatePunishment       = FIREAC.SpactatePunishment

FIREAC.AntiBlackListWeapon      = true
FIREAC.AntiAddWeapon            = false
FIREAC.AntiRemoveWeapon         = false
FIREAC.WeaponPunishment         = "BAN"

FIREAC.AntiGodMode              = true
FIREAC.GodPunishment            = "BAN"

FIREAC.AntiInvisible            = true
FIREAC.InvisiblePunishment      = "KICK"

FIREAC.AntiChangeSpeed          = true
FIREAC.SpeedPunishment          = "KICK"

FIREAC.AntiFreeCam              = false
FIREAC.CamPunishment            = "BAN"

FIREAC.AntiRainbowVehicle       = true
FIREAC.RainbowPunishment        = "BAN"

FIREAC.AntiPlateChanger         = true
FIREAC.AntiBlackListPlate       = true
FIREAC.PlatePunishment          = "BAN"

FIREAC.AntiNightVision          = true
FIREAC.AntiThermalVision        = true
FIREAC.VisionPunishment         = "BAN"

FIREAC.AntiSuperJump            = true
FIREAC.JumpPunishment           = "BAN"

FIREAC.AntiTeleport             = true
FIREAC.MaxFootDistance          = 200
FIREAC.MaxVehicleDistance       = 600
FIREAC.TeleportPunishment       = "BAN"

FIREAC.AntiNoclip               = false
FIREAC.NoclipPunishment         = "KICK"

FIREAC.AntiPedChanger           = true
FIREAC.PedChangePunishment      = "BAN"

FIREAC.AntiInfiniteStamina      = false
FIREAC.InfinitePunishment       = "WARN"


FIREAC.AntiTinyPed              = true
FIREAC.PedFlagPunishment        = "BAN"

FIREAC.AntiSuicide              = false
FIREAC.SuicidePunishment        = "WARN"

FIREAC.AntiPickupCollect        = false
FIREAC.PickupPunishment         = "BAN"

FIREAC.AntiSpamChat             = true
FIREAC.MaxMessage               = 10
FIREAC.CoolDownSec              = 3
FIREAC.ChatPunishment           = "BAN"

FIREAC.AntiBlackListCommands    = true
FIREAC.CMDPunishment            = "BAN"

FIREAC.AntiWeaponDamageChanger  = true
FIREAC.DamagePunishment         = "BAN"

FIREAC.AntiBlackListWord        = true
FIREAC.WordPunishment           = "KICK"

FIREAC.AntiBringAll             = false
FIREAC.BringAllPunishment       = "BAN"

FIREAC.AntiBlackListTrigger     = false
FIREAC.AntiSpamTrigger          = true
FIREAC.TriggerPunishment        = "BAN"

FIREAC.AntiClearPedTasks        = false
FIREAC.MaxClearPedTasks         = 5
FIREAC.CPTPunishment            = "BAN"

FIREAC.AntiTazePlayers          = true
FIREAC.MaxTazeSpam              = 3
FIREAC.TazePunishment           = "KICK"

FIREAC.AntiInject               = false
FIREAC.InjectPunishment         = "BAN"

FIREAC.AntiExplosionSpam        = true
FIREAC.MaxExplosion             = 10
FIREAC.ExplosionSpamPunishment  = "BAN"

FIREAC.AntiBlackListObject      = true
FIREAC.AntiBlackListPed         = true
FIREAC.AntiBlackListBuilding    = true
FIREAC.AntiBlackListVehicle     = true
FIREAC.EntityPunishment         = "BAN"


FIREAC.AntiSpamVehicle          = true
FIREAC.MaxVehicle               = 10

FIREAC.AntiSpamPed              = true
FIREAC.MaxPed                   = 4

FIREAC.AntiSpamObject           = true
FIREAC.MaxObject                = 15

FIREAC.SpamPunishment           = "KICK"

FIREAC.AntiChangePerm           = false
FIREAC.PermPunishment           = "BAN"

FIREAC.AntiPlaySound            = true
FIREAC.SoundPunishment          = "KICK"
