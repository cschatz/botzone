#!/usr/bin/perl -w

use CGI;
use DBI;

$upload_dir = "DOCS";

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

$query = new CGI;

$idnum = $query->param("idnum");

$sname = querysingle ("select sname from users where user_id=$idnum");
$sname =~ s/ //g;

$filename = $query->param("thefile");
$filename =~ s/.*[\/\\](.*)/$1/;
$filename = $sname . "_" . $filename;
$savename = $filename;
$version = 1;

if (-e "$upload_dir/$filename")
{
    @matches = split (/\n/, `ls $upload_dir/$filename*`);
    $lastmatch = $matches[@matches-1];
    $lastmatch =~ s/^$upload_dir\/$filename//;
    if ($lastmatch =~ /\.(\d+)/)
    {
	$version = $1 + 1;
    }
    $savename = "$filename.$version";
    # print "Save as: $savename\n";
}


runquery ("insert into docs values ($idnum, '$filename', '$savename', now())");

$upload_filehandle = $query->upload("thefile");

open UPLOADFILE, ">$upload_dir/$savename";

binmode UPLOADFILE;

while ( <$upload_filehandle> )
{
    print UPLOADFILE;
}

close UPLOADFILE;

print "Location: success.php\n\n";

