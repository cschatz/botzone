#!/usr/bin/perl

use DBI;

$connected=0;

sub connectdb
{
    if ($connected) { return; }
    # print "Connecting...\n";
    $dsn = 'DBI:mysql:cschatz_survey:mysql.websitesource.net';
    $db_user_name = 'cschatz_mysql';
    $db_password = 'cschatz1729';
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
	open (LOG, ">> exec/log") || die $!;
	print LOG "$sql\n";
	return;
    }
    connectdb();

    my $sth = $dbh->prepare($sql);
    $sth->execute() || die "!bad query";
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

$_ = <STDIN>; # skip header
while (<STDIN>)
{
    chop;
    my ($consent, $id, $age, $gender, $grade, $period, $cond, $sname) = split (/\t/);
    $sname =~ s/\'/\\\'/g;
    print "$sname\n";
    print "\t$period\t$cond\n";
    runquery ("update users set section=$period where user_id=$id and sname='$sname'");
    runquery ("update users set cond='$cond' where user_id=$id and sname='$sname'");
}
