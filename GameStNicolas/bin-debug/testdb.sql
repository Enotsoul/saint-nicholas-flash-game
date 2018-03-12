--
-- Database: `db_scores`
--

-- --------------------------------------------------------

--
-- Table structure for table `t_hiscore`
--

CREATE TABLE IF NOT EXISTS `t_hiscore` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `score` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `t_hiscore`
--

INSERT INTO `t_hiscore` (`id`, `name`, `score`) VALUES
(1, 'Your Name', 500),
(2, 'Our Name', 500),
(3, 'My name', 600);

