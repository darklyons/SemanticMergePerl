#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 1 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 'file.tmp~'],
	    { stdin => \"parser.pl\nutf-8\n/dev/tty\nend" },
	    'Self parse') ;

done_testing() ;
