<?php
  include ("top.php");
?>

<?php
  $pass = md5($_POST['passwd']);
?>

<p>
You entered ID <strong><?php echo $idnum; ?></strong>
and password <strong><?php echo $passwd; ?></strong><br />(<?php echo $pass; ?>).
</p>

<?php

  $dbHost = "";
  $dbUser = "";
  $dbPass = "";
  $dbDatabase = "";
 
  $db = mysql_connect("$dbHost", "$dbUser", "$dbPass") or die ("Error connecting to database.");
  mysql_select_db("$dbDatabase", $db) or die ("Couldn't select the database.");
  $result=mysql_query("select * from users where userid='$idnum' AND passwd='$pass'", $db);
  if (!$result) { die('Invalid query: ' . mysql_error()); }
  
  $rowCheck = mysql_num_rows($result);
  if($rowCheck > 0) {
    echo "<p><em>ID / Password OK.</em></p>";
  }
  else {
    echo "<p><em>WRONG!</em></p>";
  }
?>

<?php
   include ("bottom.html");
?>