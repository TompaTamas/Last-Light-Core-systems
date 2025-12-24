-- Last Light Skin - Database Schema

-- Outfits table (mentett ruhakészletek)
CREATE TABLE IF NOT EXISTS `outfits` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `character_id` INT(11) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `category` VARCHAR(50) DEFAULT 'Egyéb',
    `outfit_data` LONGTEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `character_id` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Characters table skin column (ha még nincs)
-- Ez a ll-core characters táblájához adódik
ALTER TABLE `characters` 
ADD COLUMN IF NOT EXISTS `skin` LONGTEXT DEFAULT NULL;

-- Skin history table (opcionális - változások követése)
CREATE TABLE IF NOT EXISTS `skin_history` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `character_id` INT(11) NOT NULL,
    `skin_data` LONGTEXT NOT NULL,
    `changed_by` VARCHAR(50) DEFAULT NULL,
    `change_reason` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `character_id` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Shared outfits table (ha engedélyezett a megosztás)
CREATE TABLE IF NOT EXISTS `shared_outfits` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `outfit_id` INT(11) NOT NULL,
    `shared_by` INT(11) NOT NULL,
    `shared_to` INT(11) DEFAULT NULL,
    `is_public` TINYINT(1) DEFAULT 0,
    `downloads` INT(11) DEFAULT 0,
    `rating` DECIMAL(3,2) DEFAULT 0.00,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `outfit_id` (`outfit_id`),
    KEY `shared_by` (`shared_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tattoo presets (tetoválás sablonok)
CREATE TABLE IF NOT EXISTS `tattoo_presets` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `collection` VARCHAR(100) NOT NULL,
    `hash_name` VARCHAR(100) NOT NULL,
    `zone` VARCHAR(50) NOT NULL,
    `category` VARCHAR(50) NOT NULL,
    `price` INT(11) DEFAULT 500,
    `is_custom` TINYINT(1) DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tattoo presets can be added manually or through admin commands
-- Example insert:
-- INSERT INTO `tattoo_presets` (`name`, `collection`, `hash_name`, `zone`, `category`, `price`) VALUES
-- ('Tribal Sun', 'mpbeach_overlays', 'MP_Bea_M_Chest_000', 'ZONE_TORSO', 'Tribal', 500);

-- Indexes for better performance
CREATE INDEX idx_character_skin ON characters(id, skin(100));
CREATE INDEX idx_outfits_character ON outfits(character_id, created_at);
CREATE INDEX idx_skin_history_character ON skin_history(character_id, created_at);