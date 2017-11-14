#!/usr/bin/perl

use DBI;

print "Content-type: text/html\n\n";

print <<EOF;
<head>
    <link rel="stylesheet" type="text/css" media="screen" href="../style.css">	
</head>
    
<div id="all">
<div id="main">
EOF

    $item = querysingle ("select item_id from varmap where item_id not in (select item_id from scores group by item_id) group by item_id limit 1", "cschatz_core");

@IDS = ();
@RESPONSES = ();
@VARS = ();

$prompt = querysingle ("select prompt from items where item_id='$item'", "cschatz_survey");
$type = querysingle ("select type from items where item_id='$item'", "cschatz_survey");
print "<table class=\"questions\">\n";

$gridprompt = "";
render_question($item, $prompt, $type);

print "</table\n>";

$mapq = runquery ("select final, orig from varmap where final='$item' or final like '${item}\\_%'", "cschatz_core");

while (my ($final, $orig) = $mapq->fetchrow_array())
{
    push (@VARS, $orig);
    push (@FINALS, $final);
}

print "<form action='score2.pl' method='post'>\n";
print "<table class=\"questions\">\n";

$n = 0;
foreach $v (@VARS)
{
    my $final = pop (@FINALS);
    my $q = runquery ("select ID, $v from responses order by ID", "cschatz_core");
    while (my ($id, $response) = $q->fetchrow_array())
    {
	
	{
	    if ($response ne "")
	    {
		render_answer ($type, $final, $id, $prompt, $response);
	    }
	}
    }
}

print <<EOF;
</table>
<input type='submit' class='button' value='Submit'>
<input type='hidden' name='item' value='$item'>
</form>
</div> <!--div main ends-->
</div> <!-- div all ends -->
</body>
</html>
EOF


exit;

sub connectdb
{
    if ($connected) { return; }
    # print "Connecting...\n";
    $dsn = 'DBI:mysql:__:__'; # dbname, hostname 
    $db_user_name = '';
    $db_password = '';
    $dbh = DBI->connect($dsn, $db_user_name, $db_password);
    # print "Ok.\n";
    $connected = 1;
}


    my ($db) = @_;
    $dsn = "DBI:mysql:$db:___"; # hostname
    $db_user_name = '';

    $dbh = DBI->connect($dsn, $db_user_name, $db_password);
    $connected = 1;
}

sub runquery
{
    my ($sql, $whichdb) = @_;

    connectdb($whichdb);

    my $sth = $dbh->prepare($sql);
    if (!$sth->execute())
    {
	$sth = $dbh->prepare("rollback");
	$sth->execute();
	die "!bad query";
    }
    return ($sth);
}

sub querysingle
{
    my $sth = runquery($_[0], $_[1]);
    
    if (my @response = $sth->fetchrow_array())
    {
	return $response[0];
    }
    else
    {
	return undef;
    }
}

sub render_answer
{
    $n++;
    my ($type, $var, $id, $prompt, $answer) = @_;

    print "<tr>";
    print "<td>$n</td>";
    print "<td>$var / $id</td>";
    
    if ($type =~ /A(\w)/)
    {
	if ($gridprompt ne "")
	{
	    my @locs = split (/\./, $answer);
	    $gridprompt =~ /^\w+ (\d+ \d+)/;
	    
	    my $args = "$item $1 0-0 E " . join (" ", @locs);

	    my $buf = `./grid.pl 0 $args`;
	    $answer = "$answer<br /><b>$buf</b>";
	}
	elsif ($answer =~ /\#\#/)
	{
	    $answer =~ s/\#\#/\n/g;
	    $answer = "<pre>\n$answer\n</pre>";
	}
	else
	{
	    $answer = "<b>$answer</b>";
	}
	print "<td>$answer</td>";
    }
    else
    {
	print "!![Not an assessment item!!";
    }
    print "</td>";
    print "<td><input type='text' class='textfield' size='10' name='S*$var:$id'/></td>";
    print "<td><input type='text' class='textfield' size='20' name='N*$var:$id'/></td>";
    print "</tr>\n";
}

sub render_question
{
    my ($item, $prompt, $type) = @_;

    my $seq = 0;


    if ($type =~ /A(\w)/)
    {
	my $subtype = $1;
	
	while ($prompt =~ /<\?GRID (.+) \?>/)
	{
	    $gridprompt = $1;
	    my $buf = `./grid.pl $seq $gridprompt`;
	    $prompt =~ s/<\?GRID (.+) \?>/$buf/;
	}
	
	if ($prompt =~ /<\?TEXT\n((.|\n)+)\?>/)
	{
	    my $content = $1;
	    my @lines = split (/\n/, $content);
	    my $numlines = @lines + 0;
	    my $newcontent = "<center><textarea name='*$item;$seq' class='textfield' cols='50' rows='$numlines'>" . "$content</textarea></center>";
	    $prompt =~ s/<\?TEXT\n((.|\n)+)\?>/$newcontent/;
	}
	
	print "<tr><td colspan='2'><span class='prompt'>($item)$prompt</span><br/>\n";
	
	if ($subtype eq "L")
	{
	    print "<center><textarea name='*$item;$seq' class='textfield' cols='50' rows='8'></textarea></center>";
	}
	elsif ($subtype eq "M")
	{
	    my $what = "radio";
	    if ($multi == 1) { $what="checkbox"; }
	    $inner = runquery ("select answer, choice_code from choices where item_id='$item' order by rand()", "cschatz_survey");
	    if ($multi) { $item="$item;$seq\[\]"; }
	    else { $item = "$item;$seq"; }
	    	    
	    print "<table class='choices'>\n";
	    while (my ($answer, $code) = $inner->fetchrow_array())
	    {
		while ($answer =~ /<\?GRID (.+) \?>/)
		{
		    my $buf = `./grid.pl $seq $1`;
		    $answer =~ s/<\?GRID (.+) \?>/$buf/;
		}
		print "<tr><td><input class='box' type='$what' name='$item' value='$code'></td><td>(<b>$code</b>)$answer</td></tr>";
	    }
	    print "</table>\n";
	    
	}
	print "</td></tr>\n";	
    }

    my $numchoices = querysingle ("select count(answer) from choices where item_id='$item'",
				  "cschatz_survey");
    
    if ($type eq "C")
    {
	print "<input type='text' name='$item;$seq' class='textfield'>";
    }
    elsif ($type eq "L")
    {
	print "<textarea name='*$item;$seq' class='textfield' cols='50' rows='4'></textarea>";
    }
    elsif ($type eq "M")
    {
	my $what = "radio";
	if ($multi == 1) { $what="checkbox"; }
	
	elsif ($numchoices > 3 && !$multi)
	{
	    print "<select name='$item;$seq'>\n<option value=''></option>\n";
	    $inner = runquery ("select answer, choice_code from choices where item_id='$item' order by choice_code", "cschatz_survey");
	    while (my ($answer, $code) = $inner->fetchrow_array())
	    {
		print "<option value='$code'>(<b>$code</b>)$answer</option>\n";
	    }
	    print "</select>\n";
	}
	else
	{
	    my $div = "<br />\n";
	    if ($numchoices <= 3) { $div = " "; }
	    $inner = runquery ("select answer, choice_code from choices where item_id='$item' order by choice_code", "cschatz_survey");
	    if ($multi) { $item="$item;$seq\[\]"; }
	    else { $item = "$item;$seq"; }
	    my $other = 0;
	    while (my ($answer, $code) = $inner->fetchrow_array())
	    {
		if ($code eq "other") { $other = 1; next; }
		print "<input class='box' type='$what' name='$item' value='$code'>(<b>$code</b>)$answer $div";
	    }
	    if ($other)
	    {
		print "<input class='box' type='$what' name='$item' value='other'> ";
		print "Other: <input class='textfield' type='text' name='$item' size=30> $div";
	    }
	}
    }
    print "</td></tr>\n";
    print "</table>\n";
}
