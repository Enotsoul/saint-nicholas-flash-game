<?php

	class hiScore{
	
		/*** (c) 2009 PIH MCT MM3 ***/
		
		function hiScore(){
			$dbname="lba_school";
			$login ="lba_school";
			$pass = "WeL0veSchool";
			$handle =mysql_connect("localhost",$login,$pass);
			$db = mysql_select_db($dbname,$handle);
		
		}
		function getHiScores(){
			//
			$sql = "SELECT * FROM t_hiscore ORDER BY score DESC LIMIT 0, 10";
			$result = mysql_query($sql);
			return $result;
		}
		function insertScore($paramObj){
			//
			$naam = addslashes($paramObj['name']);
			$score = addslashes($paramObj['score']);
			
			$sql = "INSERT INTO t_hiscore ( id, name, score) VALUES ('', '$naam','$score')";
			$result = mysql_query($sql);
			return $result;
		}
	}
?>