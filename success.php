<?php 
session_set_cookie_params (3600*24*30);
session_start(); 
include ("top.php"); 
?>

<h3>Document Submission</h3>

<div class="content">

<p>Thank you - your document was received</p>

<p>(<a href="index2.php">Back to questions</a>)</p>
</div>

<?php
   include ("bottom.html");
?>



