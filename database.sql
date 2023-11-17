CREATE TABLE IF NOT EXISTS `fireac_banlist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `STEAM` longtext NOT NULL,
  `DISCORD` longtext NOT NULL,
  `LICENSE` longtext NOT NULL,
  `LIVE` longtext NOT NULL,
  `XBL` longtext NOT NULL,
  `IP` longtext NOT NULL,
  `HWID` longtext NOT NULL,
  `BANID` longtext NOT NULL,
  `REASON` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

CREATE TABLE IF NOT EXISTS `fireac_unban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifire` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

CREATE TABLE IF NOT EXISTS `fireac_whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifire` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;