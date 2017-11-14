#!/usr/bin/perl

use DBI;

$connected=0;

my ($query) = shift @ARGV;

my $q = runquery($query);

while (my @row = $q->fetchrow_array())
{
    print join ("\@", @row) . "\n";
}

sub connectdb
{
    if ($connected) { return; }
    # print "Connecting...\n";                                                
    $dsn = 'DBI:mysql:__:__'; # dbname, hostname
    $db_password = '';
    $dbh = DBI->connect($dsn, $db_user_name, $db_password);
    # print "Ok.\n";                                                           
    $connected = 1;
}


sub runquery
{
    my ($sql) = @_;

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
