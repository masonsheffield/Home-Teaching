SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

USE ht_app;

DROP TABLE IF EXISTS `visits`;
CREATE TABLE IF NOT EXISTS `visits` (
  `visitor_ID` bigint(20) NOT NULL,
  `visitee_ID` bigint(20) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`visitor_ID`,`visitee_ID`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
