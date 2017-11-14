#!/usr/bin/perl

use DBI;

my $dsn = 'DBI:mysql:__:__'; # dbname, hostname
my $db_user_name = '';
my $db_password = '';
my $dbh = DBI->connect($dsn, $db_user_name, $db_password);

while (<STDIN>)
{
    chop;
    ($id, $id_num, $fname, $lname, $gender, $period, $assent, $consent, $dnc, $group)
	= split (/\t/, $_);

    $assent = $assent + 0;
    $consent = $consent + 0;
    $group = $group + 0;

    $sql = "insert into students values ('$id', $id_num, '$lname', '$fname', '$gender', $period, $assent, $consent, '$dnc', $group)";

    print "$sql\n";

    my $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->finish();
}

