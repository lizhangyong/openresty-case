
CREATE TABLE `resty_test`.`resty_case` (
	`id` int NOT NULL AUTO_INCREMENT,
	`mid` varchar(32) NOT NULL,
	`ip` varchar(32) NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `mid_index` USING HASH (`mid`) comment ''
) COMMENT='resty test table';

