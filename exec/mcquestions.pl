#!/usr/bin/perl

use DBI;

$connected=0;
$debug=0;
$echo=0;


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

sub runquery
{
    my ($sql) = @_;

    if ($echo == 1)
    {
	print "$sql\n";
    }

    if (($sql !~ /^select/) && $debug)
    {
	my $logfile;
	if (-e "exec/log") { $logfile = "exec/log"; }
	else { $logfile = "log"; }
	open (LOG, ">> $logfile") || die $!;
	print LOG "$sql\n";
	return;
    }

    connectdb();

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
    my $sth = runquery($_[0]);
    
    if (my @response = $sth->fetchrow_array())
    {
	return $response[0];
    }
    else
    {
	return undef;
    }
}


my @itemlist;

$outer = runquery ("select items.item_id, prompt, type, multallowed, hasgroup, min(seq) " .
		   "as ms from sequence natural join items where items.type like 'A%' " .
		   "group by item_id order by ms");


my $tot = $outer->rows();

print "found $tot items\n";

my $n = 0;

my $item, $prompt, $type, $multi, $hasgroup;

while ( ($item, $prompt, $type, $multi, $hasgroup) = $outer->fetchrow_array())
{
    print "<table class=\"questions\">\n";
    $n++;

    if ($hasgroup)
    {
	print "*** Found assessment with group!!";
	exit -1;
    }
    
    if ($prereq ne "none")
    {
	if ($finished ne $prereq)
	{
	    last;
	}
    }
        
    if ($type =~ /A(\w)/)
    {
	push (@itemlist, "$n:$item;$seq");
	my $subtype = $1;
	
	while ($prompt =~ /<\?GRID (.+) \?>/)
	{
	    my $buf = `exec/grid.pl $seq $1`;
	    $prompt =~ s/<\?GRID (.+) \?>/$buf/;
	}
	
	if ($prompt =~ /<\?TEXT\n((.|\n)+)\?>/)
	{
	    my $content = $1;
	    my @lines = split (/\n/, $content);
	    my $numlines = @lines + 0;
	    my $newcontent = "<center><textarea name='*$item;$seq' class='textfield' cols='50' rows='$numlines'>"
		. "$content</textarea></center>";
	    $prompt =~ s/<\?TEXT\n((.|\n)+)\?>/$newcontent/;
	}
	
	print <<"EOF";
	<tr><td class='number'>$n</td>
	    <td colspan='2'><span class="prompt">$prompt</span>
	    <br/>
EOF
	    if ($subtype eq "L")
	{
	    print "<center><textarea name='*$item;$seq' class='textfield' cols='50' rows='8'></textarea></center>";
	}
	elsif ($subtype eq "M")
	{
	    my $what = "radio";
	    if ($multi == 1) { $what="checkbox"; }
	    $inner = runquery ("select answer, choice_code from choices where item_id='$item' order by rand()");
	    if ($multi) { $item="$item;$seq\[\]"; }
	    else { $item = "$item;$seq"; }
	    
	    
	    print "<table class='choices'>\n";
	    while (my ($answer, $code) = $inner->fetchrow_array())
	    {
		
		while ($answer =~ /<\?GRID (.+) \?>/)
		{
		    my $buf = `exec/grid.pl $seq $1`;
		    $answer =~ s/<\?GRID (.+) \?>/$buf/;
		}
		
		print "<tr><td><input class='box' type='$what' name='$item' value='$code'></td><td>$answer</td></tr>";
	    }
	    print "</table>\n";
	    
	}
	
	print "</td></tr>\n";
	
	next;
    }
    
    
    if (!$hasgroup)
    {
	push (@itemlist, "$n:$item;$seq");
    }
    if (!$hasgroup) {
	print "<tr>\n";
	print "<td class='number'>$n</td>\n";
	print "<td><span class=\"prompt\">$prompt</span></td>\n";
	print "<td>\n";
    }
    
    my $numchoices = querysingle ("select count(answer) from choices where item_id='$item'");
    
    if ($type eq "C")
    {
	print "<input type='text' name='$item;$seq' class='textfield'>";
    }
    elsif ($type eq "L")
    {
	if ($hasgroup)
	{
	    print "</table>\n";
	    print "<table class=\"questions\">\n";
	    print "<tr>\n<td class='number'>$n</td>\n";
	    print "<td colspan='2'><span class=\"prompt\">$prompt</span></td></tr>\n";
	    $inner = runquery ("select sub_id, sub_prompt from itemgroups where item_id='$item'");
	    my $opts = "<td class='opt'><textarea name='*$item+[:SUB:]' class='textfield' cols='50' rows='4'>"
		. "</textarea></td>";
	    my $optblock;
	    my $letter = 'A';
	    while (my ($sub_item, $sub_prompt) = $inner->fetchrow_array())
	    {
		print "<tr><td colspan='2' align='left'><span class='prompt'>($letter) $sub_prompt</span></td>\n";
		$optblock = $opts;
		$optblock =~ s/\[:SUB:\]/$sub_item/g;
		print "$optblock\n";
		print "</tr>";
		push (@itemlist, "$n:$item+$sub_item;$seq");
		$letter++;
	    }
	}
	else
	{
	    print "<textarea name='*$item;$seq' class='textfield' cols='50' rows='4'></textarea>";
	}
    }
    elsif ($type eq "M")
    {
	my $what = "radio";
	if ($multi == 1) { $what="checkbox"; }
	if ($hasgroup)
	{
	    print "</table>\n";
	    print "<table class=\"questions\">\n";
	    print "<tr>\n<td class='number'>$n</td>\n";
	    print "<td><span class=\"prompt\">$prompt</span></td>\n";
	    $inner = runquery ("select answer, choice_code from choices where item_id='$item' order by choice_code");
	    my $opts;
	    while (my ($answer, $code) = $inner->fetchrow_array())
	    {
		print "<td class='opt'>$answer</td>\n";
		$opts .= "<td class='opt'><input class='box' type='$what' name='$item+[:SUB:];$seq' value='$code'></td>";
	    }
	    print "</tr>\n<tr>\n";
	    $inner = runquery ("select sub_id, sub_prompt from itemgroups where item_id='$item'");
	    my $optblock;
	    my $letter = 'A';
	    while (my ($sub_item, $sub_prompt) = $inner->fetchrow_array())
	    {
		print "<tr><td colspan='2' align='left'><span class='prompt'>($letter) $sub_prompt</span></td>\n";
		$optblock = $opts;
		$optblock =~ s/\[:SUB:\]/$sub_item/g;
		print "$optblock\n";
		print "</tr>";
		push (@itemlist, "$n:$item+$sub_item;$seq");
		$letter++;
	    }
	}
	elsif ($numchoices > 3 && !$multi)
	{
	    print "<select name='$item;$seq'>\n<option value=''></option>\n";
	    $inner = runquery ("select answer, choice_code from choices where item_id='$item' order by choice_code");
	    while (my ($answer, $code) = $inner->fetchrow_array())
	    {
		print "<option value='$code'>$answer</option>\n";
	    }
	    print "</select>\n";
	}
	else
	{
	    my $div = "<br />\n";
	    if ($numchoices <= 3) { $div = " "; }
	    $inner = runquery ("select answer, choice_code from choices where item_id='$item' order by choice_code");
	    if ($multi) { $item="$item;$seq\[\]"; }
	    else { $item = "$item;$seq"; }
	    my $other = 0;
	    while (my ($answer, $code) = $inner->fetchrow_array())
	    {
		if ($code eq "other") { $other = 1; next; }
		print "<input class='box' type='$what' name='$item' value='$code'>$answer $div";
	    }
	    if ($other)
	    {
		print "<input class='box' type='$what' name='$item' value='other'> ";
		print "Other: <input class='textfield' type='text' name='$item' size=30> $div";
	    }
	}
    }
    if (!$hasgroup)
    {
	print "</td></tr>\n";
    }
    else
    {
	last;
    }
    print "</table>\n";
}



