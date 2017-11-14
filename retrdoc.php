<?php 
session_set_cookie_params (3600*24*30);
session_start(); 
include ("top.php"); 
?>

<h3>Document Submission</h3>
<div class="content">

<p>To download your document, please provide this information:</p>

<form action="retrdoc2.php" method="post">
<table width=80%>
<tr><td align="right">Name:</td><td><input class="textfield" type="text" name="name" size=15></td></tr>
<tr><td align="right">Partner's Name:</td><td><input class="textfield" type="text" name="pname" size=15></td></tr>
<tr><td align="right">Password for the file:</td><td><input class="textfield" type="password" name="pw" size=15></td></tr>
<tr><td colspan="2">&nbsp;</td><td><input class="button" type=submit value="Retrieve"></td></tr>
</table>
</form>
</div>


<?php
   include ("bottom.html");
?>



