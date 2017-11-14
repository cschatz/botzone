#!/usr/bin/perl

$CHOICES = 8;
$IDRANGE = 2003;

while (-e ".pwlock")
{
    sleep (3);
}

system ("touch .pwlock");

dbmopen (%IDS, "ids", 0666) || die $!;

if (@ARGV != 3)
{
    print "Wrong number of arguments\n";
    system ("rm -f .pwlock");
    exit 42;
}

open (HP, "< res/hp_lexicon") || do { print "failure to open lexicon."; exit 17; };
{
    while (<HP>)
    {
	chop;
	push (@lexicon, $_);
    }
}

$VOCABSIZE = @lexicon + 0;
$delta = int($VOCABSIZE / $CHOICES);

($first, $last, $fav) = @ARGV;

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

$IDS{$id} = "used";

dbmclose (%IDS);
system ("rm .pwlock");

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

    while ($IDS{$hash} eq "used") 
    { 
	$hash = ($hash + 1) % $IDRANGE; 
	if ($hash == $orighash) { $hash = -1; last; }
    }

    return ($hash);
}

