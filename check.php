<?php
  include ("top.php");
?>

<div class="storycontent">
<form action="check2.php" method="post">
<table width=80%>
<tr><td>ID Num:</td><td><input class="textfield" type="text" name="idnum" size=5></td></tr>
<tr><td>Password:</td><td><input class="textfield" type="text" name="passwd" size=20></td></tr>
<tr><td>&nbsp;</td><td><input class="button" type=submit value="Submit"></td></tr>
</table>
</form>
</div>

<?php
   include ("bottom.html");
?>
