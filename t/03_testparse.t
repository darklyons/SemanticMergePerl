#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 2 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"test.pm\nutf-8\n/dev/tty\nend" },
	    'Parse package test.pm') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"Point.pm\nutf-8\n/dev/tty\nend" },
	    'Parse package Point.pm') ;

done_testing() ;
