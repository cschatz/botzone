#!/usr/bin/perl

my ($tot) = @ARGV;

my $numBs = int ($tot / 2);
my $numAs = $tot - $numBs;

for ($i = 0; $i < $numAs; $i++)
{
    push (@seq, 'A');
}

for ($i = 0; $i < $numBs; $i++)
{
    push (@seq, 'B');
}

while (@seq > 0)
{
    $r = int(rand(@seq+0));
    $c = splice (@seq, $r, 1);
    print "$c\n";
}
