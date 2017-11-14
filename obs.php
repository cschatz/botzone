<?php include ("top.php"); ?>

<form action="doobs.php" method=post>
Period: <select name="period">
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
</select><br/>
<textarea class="textfield" cols="80" rows="8" name="notes"></textarea><br/>
<center>
<input class="button" type="submit" value="Submit">
</center>

<?php  include ("bottom.html"); ?>


