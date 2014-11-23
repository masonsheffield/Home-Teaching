SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

USE ht_app;

DROP TABLE IF EXISTS `auth_codes`;
CREATE TABLE IF NOT EXISTS `auth_codes` (
  `code` varchar(40) NOT NULL,
  `client_id` varchar(40) NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  `redirect_uri` varchar(200) NOT NULL,
  `expires` int(11) NOT NULL,
  `scope` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;