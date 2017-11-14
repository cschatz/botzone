#!/usr/bin/perl

$CHOICES = 8;
$IDRANGE = 2003;

if (@ARGV != 1)
{
    print "** Usage: recover.pl [id-num | passwd]\n";
}

$input = $ARGV[0];

if ($input =~ /^\d+$/)
{
    if ($input >= $IDRANGE) { print "** ID out of range!\n"; exit; }
    $isid = 1;
}
elsif ($input =~ /^[a-zA-Z]+$/)
{
    $isid = 0;
}
else
{
    print "** Badly formatted input\n";
    exit;
}

open (HP, "< exec/hp_lexicon") || die $!;
{
    while (<HP>)
    {
	chop;
	push (@lexicon, $_);	
    }
}

$VOCABSIZE = @lexicon + 0;
$delta = int($VOCABSIZE / $CHOICES);

if ($isid)
{
    print "<UL>\n";
    for ($k = 0; $k < $CHOICES; $k++)
    {
	$index = ($input + $k * $delta) % $VOCABSIZE;
	$pw = $lexicon[$index];
	print "<LI>$pw</LI>\n";
    }
    print "</UL>\n";
}
else
{
    if (($result = bsearch(\@lexicon, $input)) == -1) { print "** No such password\n"; }
    else 
    { 
	for ($k = -$CHOICES; $k < $CHOICES; $k++)
	{
	    $index = ($result + $k * $delta) % $VOCABSIZE;
	    if ($index < $IDRANGE) { push (@options, $index); }
	} 
    }
    print "<UL>\n";
    foreach $o (sort { $a <=> $b; } @options)
    {
	print "<LI>$o</LI>\n";
    }
    print "</UL>\n";
}

sub bsearch
{
    my ($arrayref, $target) = @_;
    
    $begin = 0;
    $end = @$arrayref - 1;

    while ($begin <= $end)
    {
	$mid = int(($begin + $end) / 2);
	
	if ($$arrayref[$mid] eq $target) { return $mid; }
	elsif ($target lt $$arrayref[$mid])
	{
	    $end = $mid - 1;
	}
	else
	{
	    $begin = $mid + 1;
	}
    }
    return -1;
}
