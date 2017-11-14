<?php
  include ("top.php");
?>

<h3>New Student Registration (step 2)</h3>

<?php
$result = array();
$fname = trim($_POST['fname']);
$lname = $_POST['lname'];
$fav = $_POST['fav'];
$sname = ucfirst($fname) . " " . strtoupper($lname{0});
exec ("exec/manage.pl pw \"" . $fname . "\" \"" . $lname . "\" \"" . $fav . "\"", &$result, &$return);
?>

<p>Your ID Number will be: <strong>
<?php 
echo $result[0];
?>
</strong></p>

<form action="newuser3.php" method="post">
<input type="hidden" name="idnum" value="<?php echo $result[0]; ?>">
<input type="hidden" name="sname" value="<?php echo stripslashes($sname); ?>">
<input type="hidden" name="fname" value="<?php echo stripslashes($fname); ?>">
<input type="hidden" name="lname" value="<?php echo stripslashes($lname); ?>">
<p>
Now, please pick a password:
<SELECT name="passwd">
<?php
for ($i = 1; $i < sizeof($result); $i++)
{
  echo $result[$i]; 
}
?>
</SELECT>
<input class="button" type=submit value="Submit">
</p>
</form>

<?php
   include ("bottom.html");
?>