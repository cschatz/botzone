<?php 

header ("Location: obs.php");

exec ("exec/manage.pl obs " . $_POST['period'] . " '" . urlencode($_POST['notes']) . "'");



?>



