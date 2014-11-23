SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

USE ht_app;

DROP TABLE IF EXISTS `clients`;
CREATE TABLE IF NOT EXISTS `clients` (
  `app_name` tinytext NOT NULL,
  `client_id` varchar(40) NOT NULL,
  `client_secret` varchar(20) NOT NULL,
  `redirect_uri` varchar(255) NOT NULL,
  PRIMARY KEY (`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;