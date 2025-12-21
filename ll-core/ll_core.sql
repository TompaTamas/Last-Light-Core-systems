-- Last Light Core - Adatbázis séma

-- Felhasználók tábla
CREATE TABLE IF NOT EXISTS `users` (
    `identifier` VARCHAR(60) NOT NULL,
    `group` VARCHAR(50) DEFAULT 'user',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Karakterek tábla
CREATE TABLE IF NOT EXISTS `characters` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `firstname` VARCHAR(50) NOT NULL,
    `lastname` VARCHAR(50) NOT NULL,
    `dateofbirth` VARCHAR(10) NOT NULL,
    `sex` VARCHAR(1) NOT NULL DEFAULT 'm',
    `height` INT(11) NOT NULL DEFAULT 175,
    `accounts` LONGTEXT,
    `position` LONGTEXT,
    `health` INT(11) DEFAULT 200,
    `armor` INT(11) DEFAULT 0,
    `skin` LONGTEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    CONSTRAINT `characters_ibfk_1` FOREIGN KEY (`identifier`) REFERENCES `users` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inventory tábla (ll-inventory számára)
CREATE TABLE IF NOT EXISTS `inventory` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `charid` INT(11) NOT NULL,
    `item` VARCHAR(50) NOT NULL,
    `count` INT(11) NOT NULL DEFAULT 1,
    `slot` INT(11) NOT NULL,
    `metadata` LONGTEXT,
    PRIMARY KEY (`id`),
    KEY `charid` (`charid`),
    CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`charid`) REFERENCES `characters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Apokalipszis státuszok tábla
CREATE TABLE IF NOT EXISTS `apocalypse_stats` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `charid` INT(11) NOT NULL,
    `sanity` FLOAT NOT NULL DEFAULT 100.0,
    `radiation` FLOAT NOT NULL DEFAULT 0.0,
    `hunger` FLOAT NOT NULL DEFAULT 100.0,
    `thirst` FLOAT NOT NULL DEFAULT 100.0,
    `infection` FLOAT NOT NULL DEFAULT 0.0,
    `last_update` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `charid` (`charid`),
    CONSTRAINT `apocalypse_stats_ibfk_1` FOREIGN KEY (`charid`) REFERENCES `characters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexek optimalizáláshoz
CREATE INDEX idx_characters_identifier ON characters(identifier);
CREATE INDEX idx_inventory_charid ON inventory(charid);
CREATE INDEX idx_apocalypse_charid ON apocalypse_stats(charid);