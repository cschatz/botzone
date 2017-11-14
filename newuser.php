<?php
  include ("top.php");
?>

<h3>Welcome New Student!</h3>
<div class="content">

<p>Please fill out the following information:</p>
(This is just used to generate an ID number and password.)
<form action="newuser2.php" method="post">
<table width=80%>
<tr><td align="right">First Name:</td><td><input class="textfield" type="text" name="fname" size=20></td></tr>
<tr><td align="right">Last Name:</td><td><input class="textfield" type="text" name="lname" size=20></td></tr>
<tr><td align="right">A Favorite Thing:</td><td><input class="textfield" type="text" name="fav" size=20></td></tr>
<tr><td>&nbsp;</td><td><input class="button" type=submit value="Submit"></td></tr>
</table>
</form>
</div>

<?php
   include ("bottom.html");
?>