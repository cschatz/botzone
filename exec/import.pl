#!/usr/bin/perl

use DBI;

if (@ARGV != 1)
{
    print "Usage: import.pl <surveyname>\n";
    exit 0;
}

$survey = $ARGV[0];


print "Connecting...\n";
my $dsn = 'DBI:mysql:__:__'; # dbname, hostname                                
my $db_user_name = '';
my $db_password = '';
my $dbh = DBI->connect($dsn, $db_user_name, $db_password);
my @itemnumbers;
print "Ok.\n";

while (<STDIN>)
{
    chop;
    ($id, @others) = split (/\t/);
    
    my $sql = "select lname, fname, id_num from students where id = '$id'";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    if (my ($lname, $fname, $id_num) = $sth->fetchrow_array())
    {
	print "Entering data for $fname $lname ($id_num) into $survey\n";
	$k = 1;
	foreach $resp (@others)
	{
	    $resp =~ s/\"//g;
	    $resp =~ s/TRUE/1/;
	    $resp =~ s/FALSE/0/;
	    $resp =~ s/\'/~/g;
	    $item = sprintf ("%02d", $k);
	    $sql = "REPLACE INTO responses VALUES ($id_num, '$survey', '$item', '$resp')";
	    my $sth = $dbh->prepare($sql);
	    $sth->execute();
	    $k++;
	}
    }
    else
    {
	print "*** BADID: $id ***\n";
	push (@badids, $id);
    }
    $sth->finish();    
}

if (@badids > 0)
{
    print "\nWarning: Bad IDs in input:\n";
    foreach $b (@badids)
    {
	print "\t'$b'\n";
    }
}




