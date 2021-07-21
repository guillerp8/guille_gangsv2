CREATE TABLE `guille_gangsv2` (
	`gang` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`maxmembers` INT(11) NULL DEFAULT NULL,
	`ranks` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`gangStyle` INT(11) NULL DEFAULT NULL,
	`colors` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`vehicles` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`points` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`members` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`shop` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`inventory` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci'
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
