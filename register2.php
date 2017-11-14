<?php 

function err ($msg)
{
  global $regerror;
  session_start();
  session_register("regerror");
                   
  $regerror = $msg;
 
  header ("Location: register.php");

  return;
}

if (! session_is_registered("user"))
{
  // Check for emptiness
  if (empty($firstname) || empty($lastname) || empty($usernamerequest)
      || empty($password1) || empty($password2))
    {
      err ("You must fill out all information.");
      exit;
    }
  
  // Check for mismatched passwordsw
  if ($password1 != $password2)
    {
      err ("Your two password entries did not match.");
      exit;
    }

  // Check for existing username
  session_register("user");
  $user = addslashes($_POST['usernamerequest']);
  
  $dbHost = "";
  $dbUser = "";
  $dbPass = "";
  $dbDatabase = "";
  
  $db = mysql_connect("$dbHost", "$dbUser", "$dbPass") or die ("Error connecting to database.");
  mysql_select_db("$dbDatabase", $db) or die ("Couldn't select the database.");
  
  $result=mysql_query("select * from users where username='$user'", $db);
  
  //check that no rows were returned
  $rowCheck = mysql_num_rows($result);
  if($rowCheck > 0)
    {
      err ("Sorry, that username is already in use.");
      exit;
    }
  
  // If we get here, there weren't any errors from the registration form.
  $confirmstr = crypt($usernamerequest);
  
  $result=mysql_query("insert into users (username, fname, lname, password, email, confirmed)" .
		      "values ('$user', '$firstname', '$lastname', md5('$password1'), '$email', 0)",
		      $db);
  if (!$result) { die('Invalid query: ' . mysql_error()); }

  $handle = popen("/usr/local/bin/sendmail -t", "w") or die ("Error sending mail.");
  fwrite($handle, "To: " . $email . "\n") or die ("Error writing to mail.");
  fwrite($handle, "From: blossom@tutoring.perseaa.net\n");
  fwrite($handle, "Subject: Sensible Scaffodling account activation\n");
  fwrite($handle, "\nYour activation code is:\n" . $confirmstr . "\n");
  pclose($handle);
}

include ("top.html");
?>

<h3 class="storytitle">New User Registration, Continued...</h3>
<p>Your registration is almost complete!  A message has been sent to
<strong><?php echo $email; ?></strong> with a confirmation code.  Please enter the 
confirmation code below, or just follow the link provided in the email.</p>

<form action="register3.php">
Confirmation Code: <input type=text class=textfield name=confimcode>
<input type=submit class=button name=submit value='Confirm'>
</form>

<?php
include ("bottom.html");
?>