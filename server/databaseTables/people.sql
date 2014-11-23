SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

USE ht_app;

DROP TABLE IF EXISTS `people`;
CREATE TABLE IF NOT EXISTS `people` (
  `ID` bigint(20) NOT NULL,
  `name` tinytext NOT NULL,
  `auth` int(11) NOT NULL DEFAULT '1',
  `lds_username` tinytext NOT NULL,
  `lds_password` tinytext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;