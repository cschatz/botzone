<span class="left"><span id="who">
<?php
if(isset($_SESSION['idnum'])) {
  $in = true;
  echo "Logged in as <em>" . $_SESSION['idnum'] . "</em>";
}
else {
echo "Not logged in";
}
?>
</span></span>

<span class="right">
<ul id="navlist">
<?php
if ($in)
{
?>
<li><a href="logout.php">Logout</a></li>
<li><a href="submitdoc.php">Submit</a></li>
<li><a href="Materials/">Materials</a></li>
<?php
}
else
{
?>
<li><a href="Materials/">Materials</a></li>
<?php
   }
?>

</ul>
</span>