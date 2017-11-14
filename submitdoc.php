<?php 
session_set_cookie_params (3600*24*30);
session_start(); 
include ("top.php"); 
?>

<h3>Document Submission</h3>
<div class="content">

<p>Please fill out the following information to submit your file.</p>

<form action="submitdoc2.pl" method="post" enctype="multipart/form-data">
<table width=80%>
<tr><td colspan="2" align="right">Which File:</td><td><input class="textfield" type="file" name="thefile" size=15></td></tr>
<tr><td colspan="2">&nbsp;</td><td><input class="button" type=submit value="Submit"></td></tr>
</table>
<input type="hidden" name="idnum" value="<?echo $_SESSION['idnum']; ?>">
</form>
</div>

<?php
   include ("bottom.html");
?>
