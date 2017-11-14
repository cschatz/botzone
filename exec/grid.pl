#!/usr/bin/perl

$plain = 0;

my $seq = shift @ARGV;

if ($ARGV[0] eq "-")
{
    $plain = 1;
    shift @ARGV;
}

my ($item_id, $width, $height, $karelloc, $kareldir, @beeperlocs) = @ARGV;

$cells{$karelloc} = "karel-$kareldir";

foreach $L (@beeperlocs)
{
    if ($L =~ /^\*/)
    {
	$cells{substr($L,1)} = "net";
    }
    else
    {
	$cells{$L} = "beeper";
	$list .= "$L.";
    }
}

print "<table class='karel'>\n";

for ($y = $height+1; $y >= 0; $y--)
{
    print "<tr>\n";
    for ($x = 0; $x <= $width+1; $x++)
    {

	if ($x == 0 || $x == $width+1 || $y == 0 || $y == $height+1)
	{
	    print "    <td class='water'></td>\n";
	}
	else
	{
	    $str = "";
	    $val = $cells{"$x-$y"};
	    if ($val eq "") { $val = "none"; }

	    my $javascript = "";
	    if (! $plain)
	    {
		$javascript = " onClick=\"toggle('$item_id;$seq:$x-$y', '$item_id;$seq');\"";
	    }
	    
	    print "    <td id='$item_id;$seq:$x-$y' class='$val'$javascript></td>\n";
	}
    }
    print "</tr>\n";
}


print "</table>\n";

if (! $plain)
{
    print "<input type='hidden' name='*$item_id;$seq' value='$list' size='80'>\n";
}
