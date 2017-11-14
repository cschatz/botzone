#!/usr/bin/perl

@orig = ('A' .. 'Z');


for ($i = 0; $i < 26; $i++)
{
    do
    {
	$r = int (rand(@orig));
    }
    while ($orig[$r] eq chr(ord('A') + $i));
    
    push (@alpha, splice(@orig, $r, 1));
}

($text) = @ARGV;

$text =~ tr/[a-z]/[A-Z]/;

foreach $c (split (//, $text))
{
    if ($c =~ /[A-Z]/)
    {
	print $alpha[ord($c)-ord('A')];
    }
    else
    {
	print $c;
    }
}

print "\n";


