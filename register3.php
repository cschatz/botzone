<?php 

session_start();

if (session_is_registered("user"))
{
  if ($confirmcode == crypt($usernamerequest, substr($confirmcode, 0, 12)))
    { echo "Correct confirmation code!"; }
  else
    { echo "Sorry - wrong confirmation code..."; }
  
}
else
{
  header ("Location: index.php");
}

?>

