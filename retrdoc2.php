<?php 
session_set_cookie_params (3600*24*30);
session_start(); 
include ("top.php"); 
?>

<?php

exec ("exec/manage.pl retrieve '" . $_POST['name'] . "' '" . $_POST['pname'] . "' '" . $_POST['pw'] . "'", &$result);

foreach ($result as $line)
{
     echo $line . "\n";
}
?>

<?php
   include ("bottom.html");
?>



