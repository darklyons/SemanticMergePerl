#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 1 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"parser.pl\nutf-8\nt/out/parser.yaml\nend" },
	    'Self parse') ;

done_testing() ;
