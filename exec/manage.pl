#!/usr/bin/perl

use DBI;

$connected=0;
$debug=0;
$echo=0;

if (@ARGV < 1)
{
    print "!Must specify a command.\n";
    exit;
}

my ($cmd) = shift @ARGV;


if (@ARGV[0] eq "-d")
{
    shift @ARGV;
    $debug=1;
}

if ($ARGV[0] eq "-e")
{
    shift @ARGV;
    $echo = 1;
}

if ($cmd eq "bak")
{
    do_backup();
}
elsif ($cmd eq "obs")
{
    do_obs();
}
elsif ($cmd eq "q")
{
    do_query();
}
elsif ($cmd eq "retrieve")
{
    retrieve_doc();
}
elsif ($cmd eq "questions")
{
    gen_questions();
}
elsif ($cmd eq "items")
{
    do_items();
}
elsif ($cmd eq "rollback")
{
    do_rollback();
}
elsif ($cmd eq "pw")
{
    gen_pw();
}
elsif ($cmd eq "enter")
{
    do_enter();
}
else
{
    print "Unknown command '$cmd'\n"; exit;
}


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

sub do_items
{
    if (@ARGV[0] eq "-r")
    {
	shift @ARGV;
	print "Resetting...\n";
    
	if (!$debug)
	{
	    runquery ("delete from sequence");    
	    runquery ("delete from choices");
	    runquery ("delete from items");
	    runquery ("delete from itemgroups");
	    print "Reset.\n";
	}
    }

    my ($input) = @ARGV;
    
    if (!(-e $input)) { print "No such input file '$input'.\n"; exit; }

    runquery ("start transaction");

    $/ = ";;\n";
    open (IN, "< $input") || die $!;
    while (<IN>)
    {
	my $hasgroup=0;
	$_ =~ s/;;\n$//;
	my ($main, $sub) = split (/::\n/);
	if ($sub ne "") { $hasgroup=1; }
	my ($header, @options) = split (/\n/, $main);
	if ($header eq "\%\%") { last; }
	
	my $type, $multallowed=0;
	my @range;
	my ($item_id, $prompt, $other) = split (/\t/, $header);
	if ($other eq "multi") { $type = "M"; $multallowed=1; }
	elsif ($other eq "short") { $type = "C"; }
	elsif ($other eq "long") { $type = "L"; }
	else { $type = "M"; $multallowed=0 }

	if ($item_id =~ /^\+/)
	{
	    parse_assessment($main);
	    next;
	}


	runquery ("replace into items values ('$item_id', '$prompt', '$type', $multallowed, $hasgroup)");
	  
	if ($other =~ /(\d+)-(\d+)/)
	{
	    if (@options)
	    {
		print "** $prompt specifies number range and options!!\n";
		exit;
	    }
	    for ($i = $1; $i <= $2; $i++)
	    {
		push (@range, $i);
		# print "\t('$item_id', '$i', '$i')\n";
		runquery ("replace into choices values ('$item_id', '$i', '$i')");
	    }
	}
	else
	{
	    foreach $o (@options)
	    {
		my ($blank, $choice_code, $answer) = split (/\t/, $o);
		# print "\t('$item_id', '$answer', '$choice_code')\n";
		runquery ("replace into choices values ('$item_id', '$answer', '$choice_code')");
	    }
	}
	
	if ($hasgroup)
	{
	    my (@subitems) = split (/\n/, $sub);
	    foreach $s (@subitems)
	    {
		my ($sub_id, $sub_prompt) = split (/\t/, $s);
		# print "\t\t('$item_id', '$sub_id', '$sub_prompt')\n";
		runquery ("replace into itemgroups values ('$item_id', '$sub_id', '$sub_prompt')");
	    }
	}

    }

    my $seq = querysingle("select max(seq) from sequence");
    my $prereq, $prereq_name, $cond;

    $/ = "\n";

    while (<IN>)
    {
	chop;
	if ($_ !~ /^\t/)
	{
	    ($prereq, $prereq_name) = split (/\t/, $_);
	    $cond = "";
	    if ($prereq =~ /:/)
	    {
		($cond, $prereq) = split (/:/, $prereq);
		
	    }
	    if ($prereq_name ne "") 
	    {
		runquery ("replace into prereqs values ('$prereq', '$prereq_name')");
	    }
	}
	else
	{
	    my ($blank, $item_id) = split (/\t/);
	    $seq++;
	    runquery ("insert into sequence values ('$item_id', '$prereq', '$cond', $seq)");
	}
    }
    runquery ("commit");
}

sub parse_assessment()
{
    my ($content) = @_;
    
    my $type;

    if (my ($item_id, $prompt, $dummy, $options) = ($content =~ /^\+(\w+)\n((.|\n)+?)\n--\n((.|\n)+)/))
    {
	$prompt =~ s/\'/\\\'/g;

	if ($options !~ /^(( *)|(\#\#))\n/)
	{
	    runquery ("replace into items values('$item_id', '$prompt', 'AM', 0, 0)");

	    my (@ans) = split (/\n\.\n/, $options);
	    foreach $a (@ans)
	    {
		my ($code, $answer) = split (/:\n/, $a);
		runquery ("insert into choices values ('$item_id', '$answer', '$code')");
	    }
	}
	else
	{
	    if ($options =~ /^\#\#/)
	    {
		runquery ("replace into items values('$item_id', '$prompt', 'AG', 0, 0)");
	    }
	    else
	    {
		runquery ("replace into items values('$item_id', '$prompt', 'AL', 0, 0)");
	    }
	}
    }
    else
    {
	print "*** ERROR: Bad assessment item spec:\n$content\n*** END ERROR\n";
    }



}

sub gen_questions
{
    my @itemlist;

    my ($user, $finished) = @ARGV;

    chop (my $today = `date +"%Y-%m-%d"`);

    $usercond = querysingle ("select cond from users where user_id=$user");
    
    $outer = runquery ("select sequence.item_id, prompt, type, multallowed, hasgroup, seq, prereq from "
		       . "sequence inner join items using (item_id) where "
		       . "(sequence.cond = '$usercond' or sequence.cond='') "
		       . "and (sequence.item_id, sequence.seq) not in (select item_id, seq from responses where user_id=$user) "
		       . "order by sequence.seq");

    my $tot = $outer->rows();

    if ($tot == 0)
    {
	print "0\n";
	exit;
    }

    print "<h3>$tot question(s) left...</h3>\n";

    my $n = 0;

    my $item, $prompt, $type, $multi, $hasgroup, $seq, $prereq, $prereq_name;

    print "<table class=\"questions\">\n";
    while ( ($item, $prompt, $type, $multi, $hasgroup, $seq, $prereq) = $outer->fetchrow_array())
    {
	
	$n++;
	if ($n > 1 && $hasgroup) { $n--; last; }
	if ($n > 1 && $prereq ne "none" && $finished ne $prereq) { $n--; $prereq = "none"; last; }
	if ($n > 2) { $n--; last; }

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
    }

    print "</table>\n";

    if ($prereq ne "" && $prereq ne "none" && $finished ne $prereq)
    {
	my $prereq_name = querysingle ("select prereq_name from prereqs where prereq='$prereq'");
	print "<p>There are more questions, but you must first complete $prereq_name.</p>\n";
	print <<"EOF";
<p><input class='box' type="checkbox" name="complete" value="$prereq"> I have completed $prereq_name.</p>
EOF
    }
    else
    {
	print "<input type='hidden' name='itemlist' value='" . join (",", @itemlist) . "'>\n";
#	print "<input type='hidden' name='nowleft' value='" . ($tot - $n) . "'>\n";
    }
}

sub gen_pw()
{
    $CHOICES = 8;
    $IDRANGE = 2003;
    
    while (-e ".pwlock")
    {
	sleep (1);
    }

    system ("touch .pwlock");

    if (@ARGV != 3)
    {
	print "Wrong number of arguments\n";
	system ("rm -f .pwlock");
	exit 42;
    }
    
    my ($first, $last, $fav) = @ARGV;    

    open (HP, "< exec/hp_lexicon") || do { print "failure to open lexicon."; exit 17; };
    {
	while (<HP>)
	{
	    chop;
	    push (@lexicon, $_);
	}
    }
    
    $VOCABSIZE = @lexicon + 0;
    $delta = int($VOCABSIZE / $CHOICES);

    $first =~ tr/[a-z]/[A-Z]/;
    $last =~ tr/[a-z]/[A-Z]/;
    $fav =~ tr/[a-z]/[A-Z]/;
    
    $id = gethash($first . $last . $fav);
    
    $pw = $lexicon[$index];

    print "$id\n";
    for ($k = 0; $k < $CHOICES; $k++)
    {
	$index = ($id + $k * $delta) % $VOCABSIZE;
	$pw = $lexicon[$index];
	print "<OPTION>$pw</OPTION>\n";
    }
    
    system ("rm .pwlock");
}

sub gethash()
{
    my ($str) = @_;
    $hash = 5381;
    foreach $c (split //, $str)
    {
	$hash = ($hash << 5) + $hash + ord($c);
    }

    $hash = $hash % $IDRANGE;
    $orighash = $hash;

    while (defined(querysingle ("select user_id from users where user_id=$hash")))
    { 
	$hash = ($hash + 1) % $IDRANGE; 
	if ($hash == $orighash) { $hash = -1; last; }
    }

    return ($hash);
}

sub do_enter()
{
    # $debug = 1;
    # $echo = 1;

    my $long;
    my ($id, @entries) = @ARGV;
    my $item, $content, $seq;

    while (@entries > 0)
    {
	($item, $content, $seq) = splice (@entries, 0, 3);

	my $sub = "NULL";
    
	$long = 0;

    	$content =~ s/\+/ /g;
	if ($item =~ /^\*/)
	{
	    $item = substr($item, 1);
	    $long = 1;
	}
	
	if ($item =~ /\+/) 
	{
	    ($item, $sub) = split (/\+/, $item);
	    $sub = "'$sub'";
	}
	
	if ($long)
	{
	    runquery("insert into responses (user_id, item_id, sub_id, response_text, seq)" .
		     " values ($id, '$item', $sub, '$content', $seq)");
	}
	else
	{
	    runquery("insert into responses (user_id, item_id, sub_id, response_choice, seq)" .
		     " values ($id, '$item', $sub, '$content', $seq)");
	}
    }
}

sub do_query
{
    my ($query) = @ARGV;
    my $n = 0;
    my $handle = runquery ($query);
    my $index;
    if ($query =~ /^select/)
    {
	while (my @result = $handle->fetchrow_array())
	{
	    $index = $n;
	    if (length($result[0]) < 15) 
	    {
		$index = $result[0];
		shift @result;
	    }
	    print "[$index]\n";
	    my $out = join ("\n-----\n", @result);
	    $out =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
	    $out =~ s/\\(.)/$1/seg;
	    print "$out\n------\n\n";
	    $n++;
	}
    }
}

sub retrieve_doc()
{
    my ($name, $pname, $pw) = @ARGV;
    my $Q = runquery("select fname, storename, date_sub(day, interval 2 hour) from docs where name='$name' and pname='$pname' and pw='$pw'");
    if ($Q->rows() == 0)
    {
	print "<p>Sorry - no files matched.  Please try again.</p>\n";
    }
    else
    {
	print "<p>Here are the files that matched:</p>\n";
	print "<table width='500' border='1'>\n";
	print "<tr><td><b>File</b></td><td><b>When Submitted</b></td></tr>\n";
        while (my ($file, $actual, $when) = $Q->fetchrow_array())
	{
	    print "<tr>";
	    chop ($when = `date -d "$when" +"%B %d - %H:%M %P"`);
	    print qq!<td><a href="sendit.pl?n=$file&f=$actual">$file</a></td><td>$when</td></tr>\n!;
	}
	print "</table>\n";
    }
}

sub do_backup()
{
    my ($name) = @ARGV;
    chop (my $now = `date +"%m%d-%H%M"`);
    my $backname = ".save/bak-$name-$now";
    $username = '';
    $host = '';
    $pw = '';
    $dbname = '';
    system ("mysqldump -u $username -h $host --password=$pw $dbname > $backname");
}

sub do_obs()
{
    my ($period, $notes) = @ARGV;
    open (OBS, ">> exec/.obs");;

    print OBS "Pd. $period\t" . `date +"%D"`;
    print OBS urldecode($notes) . "\n==========================================\n";
    
}

sub do_rollback()
{
    my ($seq) = @ARGV;

    $q = runquery ("select item_id from sequence where seq > $seq");

    my @items;

    while (my ($item_id) = $q->fetchrow_array())
    {
	push (@items, $item_id);
    }

    runquery ("delete from sequence where seq > $seq");

    foreach $i (@items)
    {
	print "Removing $i\n";
	runquery ("delete from responses where item_id='$i' and seq > $seq");
	if (querysingle("select count(*) from responses where item_id='$i'") == 0)
	    {
		runquery ("delete from choices where item_id='$i'");
		runquery ("delete from itemgroups where item_id='$i'");
	    }
	# runquery ("delete from items where item_id='$i'");
    }


}
