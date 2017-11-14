<?php
  include ("top.php");
?>

<?php
$idnum = $_POST['idnum'];
$passwd = $_POST['passwd'];
$sname = $_POST['sname'];
$fname = $_POST['fname'];
$lname = $_POST['lname'];

?>

<h3>New Student Registration (step 3)</h3>
<?php

  $dbHost = "";
  $dbUser = "";
  $dbPass = "";
  $dbDatabase = "";
  
  $db = mysql_connect("$dbHost", "$dbUser", "$dbPass") or die ("Error connecting to database.");
  mysql_select_db("$dbDatabase", $db) or die ("Couldn't select the database.");
  
  $result=mysql_query("insert into users (user_id, passwd, sname, fname, lname)" .
		      "values ('$idnum', md5('$passwd'), '$sname', '$fname', '$lname')", $db);
  if (!$result) { die('Invalid query: ' . mysql_error()); }
else { 
?>

<p>You are now registered!
Please write down the following information in a confidential place.</p>

<p>
ID Number: <strong><?php echo $idnum; ?></strong><br/>
Login Name: <strong><?php echo stripslashes($sname); ?></strong><br />
Password: <strong><?php echo $passwd; ?></strong></p>

<p>To log in, click <a href="/">here</a>.</p>

<?php
					    }
   include ("bottom.html");
?>