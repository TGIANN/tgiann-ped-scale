
CREATE TABLE IF NOT EXISTS `tgiann_ped_scale` (
  `player` varchar(50) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `height` float DEFAULT NULL,
  UNIQUE KEY `player` (`player`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
