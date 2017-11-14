#!/usr/bin/perl

use DBI;
undef $/;

$all = <STDIN>;
$all =~ s/\%3A/:/g;
%pairs = split (/[&=]/, $all);


$item = $pairs{'item'};
undef $pairs{'item'};

foreach $k (keys %pairs)
{
    my ($valuetype, $item, $id) = ($k =~ /(\w)\*(\w+):(\d+)/);
    my $value = $pairs{$k};
    if ($valuetype eq "S")
    {
	$scores{"$id:$item"} = $value;
    }
    elsif ($valuetype eq "N")
    {
	$notes{"$id:$item"} = $value;
    }
}

foreach $key (keys %scores)
{
    my ($id, $a_item) = split (/:/, $key);
    my $score = $scores{"$id:$a_item"};
    my $note = $notes{"$id:$a_item"};

    # print "$id $item $a_item ($score) $note<br />\n";
    if ($score ne "")
    {
	runquery ("insert into scores values ($id, '$item', '$a_item', $score, '$note')", "cschatz_core");
    }
}

# print "Done\n";

print "Location: score.pl\n\n";

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
