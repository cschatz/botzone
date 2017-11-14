#!/usr/bin/perl

use CGI;


$upload_dir = "DOCS";

$query = new CGI;

$name = $query->param("n");
$file = $query->param("f");

open (IN, "< $upload_dir/$file") || die $!;

print <<"EOF";
Content-Type: application/x-octet-stream
Content-Disposition: attachment; filename=$name

EOF

while (<IN>) { print; }


