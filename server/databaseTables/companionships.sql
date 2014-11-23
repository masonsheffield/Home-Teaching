SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

USE ht_app;

DROP TABLE IF EXISTS `companionships`;
CREATE TABLE IF NOT EXISTS `companionships` (
  `a_ID` bigint(20) NOT NULL,
  `b_ID` bigint(20) NOT NULL,
  PRIMARY KEY (`a_ID`,`b_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
