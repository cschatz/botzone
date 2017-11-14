#!/usr/local/bin/perl

open (IN, "< unproc.txt") || die $!;

sub register_piece
{
    my ($piece) = @_;

    $lexicon{$piece} = 1;
}

sub register_entry
{
    my ($entry) = @_;
    
    @pieces = split (/[\-]/, $entry);

    foreach $p (@pieces)
    {
	$p =~ s/\'s$//;
	$p =~ s/[^a-zA-Z0-9]//g;
	if (length($p) > 4 && length($p) < 10)
	{
	    register_piece ($p);
	}
    }
}

while (<IN>)
{
    @matches = ($_ =~ /<strong>(.+?)<\/strong>/g);

    MATCH: foreach $m (@matches)
    {
	$m =~ s/\223|\224|\226//g;
	$m =~ s/<em>|<\/em>//g;
	$m =~ s/^ //;
	$m =~ s/ $//;
	$m =~ s/&ldquo;.+&rdquo;//g;
	$m =~ s/  / /g;
	$m =~ s/&[a-z]+;//g;

	if ($m =~ /Glossary/ || length($m) > 25)
	{
	    next MATCH;
	}

	if ($m =~ /^([^ ]*), (.*)/)
	{
	    register_entry($1);
	    @other = split (/ /, $2);
	    foreach $o (@other) { register_entry($o); }
	}
	elsif ($m !~ / /)
	{
	    register_entry($1);
	}
	else
	{
	    @sub = split (/ /, $m);
	    foreach $s (@sub) { register_entry($s); }
	}

    }
}

foreach $w (sort (keys %lexicon))
{
    print "$w\n";
}
