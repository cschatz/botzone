<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head profile="http://gmpg.org/xfn/11">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Assessment Items</title>
	<link rel="stylesheet" type="text/css" media="screen" href="style.css">	
</head>

<script type="text/javascript" src="botzone.js"></script>
	
<div id="all">

<div id="main">

<?php

exec ("exec/allquestions.pl", &$result);

foreach ($result as $line)
{
  echo $line . "\n";
}
?>


<?php
   include ("bottom.html");
?>

