SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

USE ht_app;

DROP TABLE IF EXISTS `assignments`;
CREATE TABLE IF NOT EXISTS `assignments` (
  `teacher_ID` bigint(20) NOT NULL,
  `teachee_ID` bigint(20) NOT NULL,
  PRIMARY KEY (`teacher_ID`,`teachee_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
