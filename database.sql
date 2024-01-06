-- Table for storing admin information
CREATE TABLE IF NOT EXISTS `fireac_admin` (
  `id` int(11) NOT NULL DEFAULT 1,
  `identifier` longtext NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Table for storing banned player information
CREATE TABLE IF NOT EXISTS `fireac_banlist` (
  `id` int(11) NOT NULL DEFAULT 1,
  `STEAM` longtext NOT NULL,
  `DISCORD` longtext NOT NULL,
  `LICENSE` longtext NOT NULL,
  `LIVE` longtext NOT NULL,
  `XBL` longtext NOT NULL,
  `IP` longtext NOT NULL,
  `TOKENS` longtext NOT NULL,
  `BANID` longtext NOT NULL,
  `REASON` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Table for storing unbanned player information
CREATE TABLE IF NOT EXISTS `fireac_unban` (
  `id` int(11) NOT NULL DEFAULT 1,
  `identifier` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Table for storing whitelisted player information
CREATE TABLE IF NOT EXISTS `fireac_whitelist` (
  `id` int(11) NOT NULL DEFAULT 1,
  `identifier` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
