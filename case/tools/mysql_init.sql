
CREATE TABLE `resty_test`.`resty_case` (
	`id` int NOT NULL AUTO_INCREMENT,
	`mid` varchar(32) NOT NULL,
	`ip` varchar(32) NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE `mid_index` USING BTREE (`mid`) comment ''
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

