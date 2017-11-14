<?php

//start the session
session_set_cookie_params (3600*24*30);
session_start();
session_unregister("regerror");

//check to make sure the session variable is registered
if(session_is_registered('idnum')){
  header( "Location: index2.php" );
}

else {
?> 

<?php include ("top.php"); ?>

<h3>Welcome to BotZone! Please sign in.</h3>
   (If this is your first login, just fill in your name and leave the password blank.)
<div class="content">
<?php 
   if(session_is_registered('badpassword'))
     {
       echo "<span class=\"error\">Incorrect username and/or password - please try again!</span>";
       session_unregister('badpassword');
     }
   else
     {
       echo "&nbsp;";
     }
?> 
<br />
<form action="login.php" method=post>
<table width=70%>
<tr><td align="right">Login Name or ID Number:</td><td><input class="textfield" type="text" name="sname" size=20></td></tr>
<tr><td align="right">Password:</td><td><input class="textfield" type="password" name="passwd" size=20></td></tr>
<tr><td align="right">&nbsp;</td><td><input class="button" type=submit value="Submit"></td></tr>
</table>
</form>
</div>

<?php
   include ("bottom.html");
   }
?>


