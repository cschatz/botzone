#!/usr/bin/perl

use DBI;

print "Connecting...\n";
my $dsn = 'DBI:mysql:__:__'; # dbname, hostname
my $db_user_name = '';
my $db_password = '';
my $dbh = DBI->connect($dsn, $db_user_name, $db_password);
my @itemnumbers;
print "Ok.\n";

while (one_survey()) { }

sub clean_text
{
    my ($textref) = @_;

    $$textref =~ s/\'/~/g;
    $$textref =~ s/\n/\|\%\|/g;
}

sub one_survey
{
    print "\n";
    my $survey = "";
    while ($survey eq "")
    {
	print "|Survey name [.]=Done> ";
	$survey = <STDIN>;
	chop $survey;
	if ($survey eq ".") { return 0; }
    }
    print "\n";

    while (one_student ($survey)) { }

    return 1;
}

sub do_items
{
    my ($survey, $fname, $lname, $id_num) = @_;

    print "------------------------------------------------------\n";
    print " Survey \"$survey\" | $fname $lname ($id_num)\n";
    print "------------------------------------------------------\n";
    print " [-] Back up  [/] Sub-items  [=] Paragraph  [.] Done\n";
    print "------------------------------------------------------\n";
    
    my %responsemap;
    my $item;
    my $backtrackStage = 0;

    ITEMLOOP: while (1)
    {
	$item = "";
	foreach $n (@itemnumbers)
	{
	    $item .= sprintf ("%02d.", $n);
	}
	chop $item;
	if ($backtrackStage > 0)
	{
	    delete $responsemap{$item};
	    $backtrackStage --;
	}
	else
	{
	    print "|$item> ";
	    chop (my $response = <STDIN>);
	    
	    if ($response eq "/") 
	    {
		push (@itemnumbers, 1);
	    }
	    elsif ($response eq ".")
	    {
		pop (@itemnumbers);
		if (@itemnumbers == 0) { last ITEMLOOP; }
		$itemnumbers[@itemnumbers-1] ++;
	    }
	    elsif ($response eq "-")
	    {
		my $k = \$itemnumbers[@itemnumbers-1];
		if ($$k > 1)
		{
		    $backtrackStage = 1;
		    $$k -= 1;
		    print "\033\[1A";
		    print "\033\[2K";
		}
		
		print "\033\[1A";
		print "\033\[2K";
	    }
	    else
	    {
		if ($response eq "=")
		{
		    my $paragraph = "";
		    $response = "";
		    do
		    {
			$paragraph .= $response;
			$response = <STDIN>;
		    }
		    while ($response ne ".\n");
		    $response = $paragraph;
		}
		clean_text(\$response);
		
		$responsemap{$item} = $response;
       		
		$itemnumbers[@itemnumbers-1] ++;
	    }
	}
    }
    
    foreach $k (sort (keys %responsemap)) 
    { 
	my $resp = $responsemap{$k};
	print "$id_num\t$survey\t$k\t$resp\n";
	$sql = "REPLACE INTO responses VALUES ($id_num, '$survey', '$k', '$resp')";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
    }
    
    print "\n";
    
}

sub one_student
{
    my ($survey) = @_;
    my $input = "";
    
    while ($input eq "")
    {
	print "|Student ID ([.]=Done)> ";
	$input = <STDIN>;
	chop $input;
    }

    if ($input eq ".") { return 0; }

    $sql = "select lname, fname, id_num from students where id = '$input'";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    if (my ($lname, $fname, $id_num) = $sth->fetchrow_array())
    {
	push (@itemnumbers, 1);
	do_items($survey, $fname, $lname, $id_num);
    }
    else
    {
	print "\tNO SUCH ID!\n";
    }
    $sth->finish();
    return 1;
}


