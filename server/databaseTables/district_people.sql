SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

USE ht_app;

DROP TABLE IF EXISTS `district_people`;
CREATE TABLE IF NOT EXISTS `district_people` (
  `district_ID` bigint(20) NOT NULL,
  `person_ID` bigint(20) NOT NULL,
  PRIMARY KEY (`district_ID`,`person_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
