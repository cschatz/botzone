<?php 
session_set_cookie_params (3600*24*30);
session_start(); 


$argstring = "";

foreach ($_POST as $nameandseq=>$val)
{
  if ($nameandseq == "complete")
    {
      $_SESSION['finished'] = $val;
      last;
    }

  if ($nameandseq != "itemlist" && $nameandseq != "nowleft")
    {
      
      list ($name, $seq) = split (";", $nameandseq);
      $result = array();
      if (is_array($_POST[$nameandseq]))
	{
	  foreach ($_POST[$nameandseq] as $i=>$elem)
	    {
	  
	      //	      exec ("exec/manage.pl enter " . $_SESSION['idnum'] . " " . $name . " '" 
	      // urlencode($elem) . "' " . $seq, &$result, &$return);
	      $argstring .= " " . $name . " '" . urlencode($elem) . "' " . $seq;
	    }
	}
      else
	{
	  //exec ("exec/manage.pl enter " . $_SESSION['idnum'] . " " . $name . " '" 
	  //	. urlencode($val) . "' " . $seq, &$result, &$return);
	  $argstring .= " " . $name . " '" . urlencode($val) . "' " . $seq;
	}
    }
}

exec ("exec/manage.pl enter " . $_SESSION['idnum'] . $argstring);

header ("Location: index2.php");

?>



