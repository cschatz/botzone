#!/usr/local/bin/perl

for ($c = "a", $i = 0; $i < 26; $i++, $c++)
{
    $url = "http://www.mugglenet.com/infosection/glossary/$c.shtml";
    print "Grabbing $url\n...";

    system ("lynx --source $url >> unproc.txt");
    print "\tDone.\n";
}


