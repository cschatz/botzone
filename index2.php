<?php 
session_set_cookie_params (3600*24*30);
session_start(); 
include ("top.php"); 
?>

<script type="text/javascript" src="botzone.js"></script>

<form method="post" action="answer.php" name="surveyform" onSubmit="return formcheck(surveyform);">

<?php

exec ("exec/manage.pl questions " . $_SESSION['idnum'] . " " . $_SESSION['finished'], &$result);

if ($result[0] == "0")
{
  header ("Location: done.php");
}
else
{
  foreach ($result as $line)
    {
      echo $line . "\n";
    }
}
?>


<center>
<input class="button" type="submit" value="Continue"></td></tr>
</center>

</form>

<?php
   include ("bottom.html");
?>

