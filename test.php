<?php include ("top.php"); ?>

<script type="text/javascript" src="botzone.js"></script>

<form method="post" action="answer.php" name="surveyform" onSubmit="return formcheck(surveyform);">

<?php

    system ("exec/grid.pl 4 kbasics 8 5 1-1 N 2-1 2-2 2-4");

?>

</textarea>

<center>
<input class="button" type="submit" value="Continue"></td></tr>
</center>

</form>


<?php include ("bottom.html"); ?>


