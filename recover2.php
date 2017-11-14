<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head profile="http://gmpg.org/xfn/11">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>BotZone - Password / ID Recovery</title>
	<link rel="stylesheet" type="text/css" media="screen" href="style.css">	
</head>
	
<div id="all">

<div id="main">

<p>ID / Password Recovery</p>

<p>Okay - One of these should look familiar:</p>

<?php
exec ("exec/recover.pl " . $_POST['info'], &$result);

foreach ($result as $line)
{
     echo $line . "\n";
}
?>

</div> <!--div main ends-->

</div> <!-- div all ends -->

</body>
</html>

