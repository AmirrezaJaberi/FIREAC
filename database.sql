CREATE TABLE IF NOT EXISTS `fireac_admin` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `identifier` varchar(128) NOT NULL,
  `player_name` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fireac_admin_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS `fireac_banlist` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `PLAYER_NAME` varchar(128) DEFAULT NULL,
  `STEAM` varchar(128) NOT NULL DEFAULT '__NONE__',
  `DISCORD` varchar(64) NOT NULL DEFAULT '__NONE__',
  `LICENSE` varchar(128) NOT NULL DEFAULT '__NONE__',
  `LIVE` varchar(128) NOT NULL DEFAULT '__NONE__',
  `XBL` varchar(128) NOT NULL DEFAULT '__NONE__',
  `IP` varchar(64) NOT NULL DEFAULT '__NONE__',
  `TOKENS` longtext NOT NULL,
  `BANID` bigint unsigned NOT NULL,
  `REASON` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fireac_banid` (`BANID`),
  KEY `idx_fireac_license` (`LICENSE`),
  KEY `idx_fireac_discord` (`DISCORD`),
  KEY `idx_fireac_ip` (`IP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS `fireac_unban` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `identifier` varchar(128) NOT NULL,
  `player_name` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fireac_unban_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS `fireac_whitelist` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `identifier` varchar(128) NOT NULL,
  `player_name` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fireac_whitelist_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
